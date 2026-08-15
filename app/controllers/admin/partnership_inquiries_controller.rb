module Admin
  class PartnershipInquiriesController < ApplicationController
    def index
      @partnership_inquiries = PartnershipInquiry.recent
    end

    def show
      @partnership_inquiry = PartnershipInquiry.find(params[:id])
    end

    def update
      @partnership_inquiry = PartnershipInquiry.find(params[:id])
      if @partnership_inquiry.update(params.require(:partnership_inquiry).permit(:status))
        redirect_to admin_partnership_inquiries_path, notice: "Partnership inquiry status updated."
      else
        redirect_to admin_partnership_inquiries_path, alert: "Failed to update status."
      end
    end

    def destroy
      @partnership_inquiry = PartnershipInquiry.find(params[:id])
      @partnership_inquiry.destroy
      redirect_back fallback_location: admin_dashboard_path, notice: "Partnership proposal deleted successfully."
    end
  end
end
