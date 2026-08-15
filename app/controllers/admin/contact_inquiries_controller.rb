module Admin
  class ContactInquiriesController < ApplicationController
    def index
      @contact_inquiries = ContactInquiry.recent
    end

    def show
      @contact_inquiry = ContactInquiry.find(params[:id])
    end

    def update
      @contact_inquiry = ContactInquiry.find(params[:id])
      if @contact_inquiry.update(params.require(:contact_inquiry).permit(:status))
        redirect_to admin_contact_inquiries_path, notice: "Contact inquiry status updated."
      else
        render :show, status: :unprocessable_entity
      end
    end

    def destroy
      @contact_inquiry = ContactInquiry.find(params[:id])
      @contact_inquiry.destroy
      redirect_back fallback_location: admin_dashboard_path, notice: "Contact inquiry deleted successfully."
    end
  end
end
