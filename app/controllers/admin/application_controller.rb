module Admin
  class ApplicationController < ::ApplicationController
    layout "admin"

    before_action :require_admin!

    helper_method :current_user, :logged_in?

    private

    def current_user
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end

    def logged_in?
      current_user.present?
    end

    def require_admin!
      unless logged_in?
        redirect_to admin_login_path, alert: "Please log in with admin credentials to access the Foundation Dashboard."
      end
    end
  end
end
