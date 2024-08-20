class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params.dig(:session, :email)&.downcase
    if user.try :authenticate, params.dig(:session, :password)
      success_log_in user
    else
      invalid_log_in
    end
  end

  def destroy
    log_out
    redirect_to root_url, status: :see_other
  end

  private

  def success_log_in user
    reset_session
    log_in user
    params.dig(:session, :remember_me) == "1" ? remember(user) : forget(user)
    remember user
    if user.role_admin?
      redirect_to admin_orders_path, status: :see_other
    else
      redirect_to root_path, status: :see_other
    end
  end

  def invalid_log_in
    flash.now[:danger] = t "flash.invalid_email_password_combination"
    render :new, status: :unprocessable_entity
  end
end
