module Admin
  class DonationsController < ApplicationController
    before_action :set_donation, only: [:show, :update]

    def index
      @status = params[:status]
      @donations = case @status
                   when "pending"
                     Donation.awaiting_payment
                   when "receipt_uploaded"
                     Donation.pending_verification
                   when "successful"
                     Donation.successful
                   else
                     Donation.recent
                   end

      @total_donations_count = Donation.count
      @pending_receipts_count = Donation.pending_verification.count
      @total_amount_raised = Donation.successful.sum(:amount)
    end

    def show
    end

    def update
      if @donation.update(donation_params)
        redirect_to admin_donations_path, notice: "Donation status for reference #{@donation.payment_reference} updated to #{@donation.status_display_name}."
      else
        redirect_to admin_donations_path, alert: "Failed to update donation status."
      end
    end

    private

    def set_donation
      @donation = Donation.find(params[:id])
    end

    def donation_params
      params.require(:donation).permit(:status, :depositor_name, :notes, :receipt_url)
    end
  end
end
