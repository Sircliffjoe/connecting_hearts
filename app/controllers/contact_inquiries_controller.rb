class ContactInquiriesController < ApplicationController
  include SpamProtection

  def new
    @contact_inquiry = ContactInquiry.new
  end

  def create
    return unless verify_spam_and_rate_limit!(text_content: "#{params.dig(:contact_inquiry, :subject)} #{params.dig(:contact_inquiry, :message)}")

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
