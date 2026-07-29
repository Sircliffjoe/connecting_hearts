class ContactInquiriesController < ApplicationController
  def new
    @contact_inquiry = ContactInquiry.new
  end

  def create
    @contact_inquiry = ContactInquiry.new(contact_params)
    if @contact_inquiry.save
      redirect_to contact_path, notice: "Thank you! Your message has been received. Our Warri team will get back to you shortly."
    else
      flash.now[:error] = "Please check the form for missing or invalid information."
      render "pages/contact", status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact_inquiry).permit(:name, :email, :subject, :message)
  end
end
