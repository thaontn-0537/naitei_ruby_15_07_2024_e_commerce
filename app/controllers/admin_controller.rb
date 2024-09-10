class AdminController < ApplicationController
  before_action :logged_in_user
  before_action :authorize_admin!

  def logged_in_user
    return if user_signed_in?

    store_location_for :user, request.fullpath
    flash[:danger] = t "message.auth.login"
    redirect_to login_path
  end

  def authorize_admin!
    authorize! :manage, :all
  end
end
