module Admin
  class SessionsController < ApplicationController
    skip_before_action :require_admin!, only: [:new, :create]

    def new
    end

    def create
      user = User.find_by(email: params[:email]&.downcase&.strip)
      if user&.authenticate(params[:password])
        session[:user_id] = user.id
        redirect_to admin_dashboard_path, notice: "Welcome back, #{user.name}."
      else
        flash.now[:error] = "Invalid email or password."
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session[:user_id] = nil
      redirect_to root_path, notice: "Logged out successfully."
    end
  end
end
