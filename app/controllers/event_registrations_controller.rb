class EventRegistrationsController < ApplicationController
  def create
    @registration = EventRegistration.new(registration_params)
    if @registration.save
      redirect_to experiences_path, notice: "Registration successful! We look forward to seeing you at the Connecting Hearts Experience."
    else
      redirect_to experiences_path, error: "Unable to complete registration. Please check your information."
    end
  end

  private

  def registration_params
    params.require(:event_registration).permit(:event_id, :full_name, :email, :phone, :attendance_type)
  end
end
