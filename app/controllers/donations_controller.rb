class DonationsController < ApplicationController
  def new
    @donation = Donation.new(
      purpose: params[:purpose] || "General Foundation Support",
      amount: 5000,
      currency: "NGN"
    )
  end

  def create
    @donation = Donation.new(donation_params)
    @donation.payment_reference = "CHF-#{SecureRandom.hex(6).upcase}"
    @donation.status = "successful" # Simulating Paystack/Flutterwave sandbox response

    if @donation.save
      redirect_to confirmation_donations_path(ref: @donation.payment_reference), notice: "Thank you for your generous financial support!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def confirmation
    @donation = Donation.find_by(payment_reference: params[:ref])
  end

  private

  def donation_params
    params.require(:donation).permit(:donor_name, :donor_email, :amount, :currency, :purpose)
  end
end
