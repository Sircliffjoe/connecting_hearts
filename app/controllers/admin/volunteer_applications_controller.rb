module Admin
  class VolunteerApplicationsController < ApplicationController
    def index
      @volunteer_applications = VolunteerApplication.recent
    end

    def show
      @volunteer_application = VolunteerApplication.find(params[:id])
    end

    def update
      @volunteer_application = VolunteerApplication.find(params[:id])
      if @volunteer_application.update(params.require(:volunteer_application).permit(:status, :notes))
        redirect_to admin_volunteer_applications_path, notice: "Volunteer application updated."
      else
        render :show, status: :unprocessable_entity
      end
    end
  end
end
