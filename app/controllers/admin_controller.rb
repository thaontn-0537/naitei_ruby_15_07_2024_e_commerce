class AdminController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "message.auth.login"
    redirect_to login_path
  end

  def admin_user
    return if current_user&.role_admin?

    flash[:danger] = t "message.auth.admin"
    redirect_to root_path
  end
end
