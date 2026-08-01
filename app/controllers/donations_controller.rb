class DonationsController < ApplicationController
  include SpamProtection

  def new
    @donation = Donation.new(
      purpose: params[:purpose] || "General Foundation Support",
      amount: 5000,
      currency: "NGN"
    )
  end

  def create
    return unless verify_spam_and_rate_limit!

    @donation = Donation.new(donation_params)
    @donation.currency = "NGN"
    @donation.payment_reference = "CHF-#{SecureRandom.hex(6).upcase}"
    @donation.status = "pending"

    if @donation.save
      redirect_to confirmation_donations_path(ref: @donation.payment_reference), notice: "Donation initiated! Please complete transfer using bank details below."
    else
      render :new, status: :unprocessable_entity
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
    params.require(:donation).permit(:donor_name, :donor_email, :amount, :purpose)
  end

  def cloudinary_configured?
    ENV["CLOUDINARY_URL"].present? || 
      (ENV["CLOUDINARY_CLOUD_NAME"].present? && ENV["CLOUDINARY_API_KEY"].present? && ENV["CLOUDINARY_API_SECRET"].present?)
  end
end
