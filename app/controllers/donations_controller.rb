class DonationsController < ApplicationController
  include SpamProtection

  def new
    @donation = Donation.new(
      purpose: params[:purpose] || "General Foundation Support",
      amount: 5000,
      currency: "NGN"
    )
    @payment_method = params[:payment_method] || "paystack"
  end

  def create
    return unless verify_spam_and_rate_limit!

    @donation = Donation.new(donation_params)
    @donation.currency = params.dig(:donation, :currency).presence || "NGN"
    @donation.payment_reference = "CHF-#{SecureRandom.hex(6).upcase}"
    @donation.status = "pending"
    @payment_method = params[:payment_method] || "paystack"

    if @donation.save
      respond_to do |format|
        format.json do
          render json: {
            success: true,
            payment_method: @payment_method,
            payment_reference: @donation.payment_reference,
            amount_in_kobo: (@donation.amount * 100).to_i,
            amount: @donation.amount,
            currency: @donation.currency,
            donor_name: @donation.donor_name.presence || "Anonymous Donor",
            donor_email: @donation.donor_email,
            purpose: @donation.purpose,
            public_key: PaymentGateways::PaystackService.public_key,
            callback_url: callback_donations_url(reference: @donation.payment_reference),
            confirmation_url: confirmation_donations_path(ref: @donation.payment_reference)
          }
        end

        format.html do
          if @payment_method == "paystack"
            initialize_and_redirect_paystack(@donation)
          else
            redirect_to confirmation_donations_path(ref: @donation.payment_reference), notice: "Donation initiated! Please complete transfer using bank details below."
          end
        end
      end
    else
      respond_to do |format|
        format.json do
          render json: {
            success: false,
            errors: @donation.errors.full_messages
          }, status: :unprocessable_entity
        end

        format.html do
          render :new, status: :unprocessable_entity
        end
      end
    end
  end

  def callback
    ref = params[:reference].presence || params[:trxref].presence
    if ref.blank?
      redirect_to new_donation_path, alert: "Payment reference not found."
      return
    end

    @donation = Donation.find_by(payment_reference: ref)
    if @donation.nil?
      redirect_to new_donation_path, alert: "Donation record not found for reference #{ref}."
      return
    end

    verification = PaymentGateways::PaystackService.verify_transaction(ref)

    if verification["status"] == true && verification.dig("data", "status") == "success"
      data = verification["data"]
      channel = data["channel"] || "card"
      gateway_id = data["id"]
      paid_amount = (data["amount"].to_f / 100).round(2)

      @donation.update!(
        status: "successful",
        amount: paid_amount.positive? ? paid_amount : @donation.amount,
        notes: "Paid online via Paystack (Channel: #{channel}, Gateway ID: #{gateway_id})"
      )

      BrevoService.send_donation_receipt(@donation) rescue nil

      redirect_to confirmation_donations_path(ref: @donation.payment_reference), notice: "Payment successful! Thank you for your generous donation."
    else
      err_msg = verification["message"] || "Payment verification incomplete."
      redirect_to confirmation_donations_path(ref: @donation.payment_reference), alert: "Paystack status: #{err_msg}. You can complete donation via bank transfer below."
    end
  end

  def initialize_paystack
    @donation = Donation.find_by(payment_reference: params[:payment_reference]) || Donation.find_by(id: params[:id])
    if @donation.nil?
      respond_to do |format|
        format.json { render json: { success: false, errors: ["Donation record not found."] }, status: :not_found }
        format.html { redirect_to new_donation_path, alert: "Donation record not found." }
      end
      return
    end

    respond_to do |format|
      format.json do
        render json: {
          success: true,
          payment_reference: @donation.payment_reference,
          amount_in_kobo: (@donation.amount * 100).to_i,
          amount: @donation.amount,
          currency: @donation.currency || "NGN",
          donor_name: @donation.donor_name.presence || "Anonymous Donor",
          donor_email: @donation.donor_email,
          purpose: @donation.purpose,
          public_key: PaymentGateways::PaystackService.public_key,
          callback_url: callback_donations_url(reference: @donation.payment_reference),
          confirmation_url: confirmation_donations_path(ref: @donation.payment_reference)
        }
      end
      format.html do
        initialize_and_redirect_paystack(@donation)
      end
    end
  end

  def confirmation
    @donation = Donation.find_by(payment_reference: params[:ref])
    if @donation.nil?
      redirect_to new_donation_path, alert: "Donation record not found."
    end
  end

  def upload_receipt
    @donation = Donation.find_by(payment_reference: params[:payment_reference]) || Donation.find_by(id: params[:id])

    if @donation.nil?
      redirect_to new_donation_path, alert: "Donation record not found."
      return
    end

    file = params[:receipt_file]
    if file.present?
      begin
        if cloudinary_configured?
          upload_options = { resource_type: "auto", folder: "connecting_hearts/receipts" }
          response = Cloudinary::Uploader.upload(file.tempfile.path, upload_options)
          receipt_url = response["secure_url"]
        else
          filename = "receipt_#{Time.current.to_i}_#{file.original_filename.parameterize}"
          uploads_dir = Rails.root.join("public", "uploads", "receipts")
          FileUtils.mkdir_p(uploads_dir)
          file_path = uploads_dir.join(filename)
          File.open(file_path, "wb") { |f| f.write(file.read) }
          receipt_url = "/uploads/receipts/#{filename}"
        end

        @donation.update!(
          receipt_url: receipt_url,
          depositor_name: params[:depositor_name].presence || @donation.depositor_name,
          notes: params[:notes].presence || @donation.notes,
          status: "receipt_uploaded"
        )

        redirect_to confirmation_donations_path(ref: @donation.payment_reference), notice: "Payment receipt uploaded successfully! Thank you. Our team will verify your transfer shortly."
      rescue => e
        redirect_to confirmation_donations_path(ref: @donation.payment_reference), alert: "Failed to upload receipt: #{e.message}"
      end
    else
      redirect_to confirmation_donations_path(ref: @donation.payment_reference), alert: "Please select a valid payment receipt file (image or PDF) to upload."
    end
  end

  private

  def donation_params
    params.require(:donation).permit(:donor_name, :donor_email, :amount, :currency, :purpose)
  end

  def initialize_and_redirect_paystack(donation)
    amount_in_kobo = (donation.amount * 100).to_i
    callback_url = callback_donations_url

    response = PaymentGateways::PaystackService.initialize_transaction(
      email: donation.donor_email,
      amount_in_kobo: amount_in_kobo,
      reference: donation.payment_reference,
      callback_url: callback_url,
      metadata: {
        donor_name: donation.donor_name,
        purpose: donation.purpose,
        custom_fields: [
          { display_name: "Purpose", variable_name: "purpose", value: donation.purpose },
          { display_name: "Reference Code", variable_name: "reference", value: donation.payment_reference }
        ]
      }
    )

    if response["status"] == true && response.dig("data", "authorization_url").present?
      redirect_to response["data"]["authorization_url"], allow_other_host: true
    else
      Rails.logger.error("[Paystack] Initialization failed: #{response.inspect}")
      redirect_to confirmation_donations_path(ref: donation.payment_reference), alert: "Unable to redirect to Paystack (#{response['message'] || 'Service unavailable'}). Please proceed with direct bank transfer below."
    end
  end

  def cloudinary_configured?
    ENV["CLOUDINARY_URL"].present? || 
      (ENV["CLOUDINARY_CLOUD_NAME"].present? && ENV["CLOUDINARY_API_KEY"].present? && ENV["CLOUDINARY_API_SECRET"].present?)
  end
end
