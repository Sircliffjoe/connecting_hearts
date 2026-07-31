class EventRegistrationsController < ApplicationController
  include SpamProtection

  def create
    return unless verify_spam_and_rate_limit!

    @registration = EventRegistration.new(registration_params)
    if @registration.save
      # Sync registration with Eventro API (eventro.africa)
      EventroApiService.register_participant(@registration)
      redirect_to experiences_path, notice: "Registration successful! Your spot has been confirmed for the Connecting Hearts Experience."
    else
      redirect_to experiences_path, alert: "Unable to complete registration. Please check your information."
    end
  end

  private

  def registration_params
    params.require(:event_registration).permit(:event_id, :full_name, :email, :phone, :attendance_type)
  end
end
