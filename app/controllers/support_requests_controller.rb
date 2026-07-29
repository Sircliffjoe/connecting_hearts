class SupportRequestsController < ApplicationController
  include SpamProtection

  def new
    @support_request = SupportRequest.new(
      support_category: params[:category] || "Individual Counseling"
    )
  end

  def create
    return unless verify_spam_and_rate_limit!(text_content: "#{params.dig(:support_request, :situation_description)}")

    @support_request = SupportRequest.new(support_request_params)
    if @support_request.save
      redirect_to confirmation_support_requests_path, notice: "Your support request has been received with care."
    else
      flash.now[:error] = "Please check the form for missing information."
      render :new, status: :unprocessable_entity
    end
  end

  def confirmation
  end

  private

  def support_request_params
    params.require(:support_request).permit(
      :full_name, :email, :phone, :preferred_contact_method,
      :support_category, :session_format, :situation_description, :consent_given
    )
  end
end
