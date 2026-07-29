class VolunteerApplicationsController < ApplicationController
  include SpamProtection

  def new
    @volunteer_application = VolunteerApplication.new
  end

  def create
    return unless verify_spam_and_rate_limit!(text_content: "#{params.dig(:volunteer_application, :skills)} #{params.dig(:volunteer_application, :notes)}")

    @volunteer_application = VolunteerApplication.new(volunteer_params)
    if @volunteer_application.save
      redirect_to confirmation_volunteer_applications_path, notice: "Thank you for applying to volunteer!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def confirmation
  end

  private

  def volunteer_params
    params.require(:volunteer_application).permit(:full_name, :email, :phone, :role_interest, :skills, :availability)
  end
end
