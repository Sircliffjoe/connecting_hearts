class PartnershipInquiriesController < ApplicationController
  def new
    @partnership_inquiry = PartnershipInquiry.new
  end

  def create
    @partnership_inquiry = PartnershipInquiry.new(partnership_params)
    if @partnership_inquiry.save
      redirect_to confirmation_partnership_inquiries_path, notice: "Thank you! Your partnership proposal has been submitted."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def confirmation
  end

  private

  def partnership_params
    params.require(:partnership_inquiry).permit(:organization_name, :contact_person, :email, :phone, :partnership_type, :message)
  end
end
