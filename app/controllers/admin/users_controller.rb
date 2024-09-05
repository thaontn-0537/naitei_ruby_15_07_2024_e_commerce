class Admin::UsersController < AdminController
  def index
    @q = User.ransack params[:q]
    @query = params[:q][:user_name_or_email_cont]
    session[:search_query] = @query
    @pagy, @users_search = pagy(
      @q.result,
      limit: Settings.page_10
    )
    render :index
  end
end
