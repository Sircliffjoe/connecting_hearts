module Admin
  class UsersController < ApplicationController
    before_action :set_user, only: [:show, :edit, :update, :destroy]

    def index
      @users = User.order(created_at: :desc)
    end

    def show
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      if @user.save
        redirect_to admin_users_path, notice: "Team member created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      params_to_update = user_params
      if params_to_update[:password].blank?
        params_to_update = params_to_update.except(:password, :password_confirmation)
      end

      if @user.update(params_to_update)
        redirect_to admin_users_path, notice: "Team member updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == current_user
        redirect_to admin_users_path, alert: "You cannot delete your own account."
      else
        @user.destroy
        redirect_to admin_users_path, notice: "Team member deleted."
      end
    end

    def profile
      @user = current_user
    end

    def update_profile
      @user = current_user
      params_to_update = user_params
      if params_to_update[:password].blank?
        params_to_update = params_to_update.except(:password, :password_confirmation)
      end

      if @user.update(params_to_update)
        redirect_to admin_profile_path, notice: "Profile updated successfully."
      else
        render :profile, status: :unprocessable_entity
      end
    end

    def settings
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :role, :image_url, :password, :password_confirmation)
    end
  end
end
