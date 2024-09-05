class ProductsController < ApplicationController
  load_and_authorize_resource only: :show
  def search
    @categories = Category.all
    @query = params[:q][:product_name_cont]
    session[:search_query] = @query
    @pagy, @products_search = pagy(
      @q.result
      .search,
      limit: Settings.page_10
    )
    @total_results = @q.result.count
    render :search
  end

  def filter_by_category
    @categories = Category.all
    @query = session[:search_query]
    @filter = Product.ransack(params[:q])
    @pagy, @products_filtered = pagy(
      @filter.result
      .search,
      limit: Settings.page_10
    )
    @total_results = @filter.result.count
    render :search
  end

  def show
    update_product_rating
    load_feedbacks
    load_cart_for_current_user
  end

  private

  def update_product_rating
    @product.update_rating
  end

  def load_feedbacks
    @feedbacks = @product.feedbacks
                         .includes(:user)
                         .sort_by_field(params[:sort_by], params[:direction])
  end

  def load_cart_for_current_user
    return unless current_user

    @cart = current_user.carts.find_by(product_id: @product.id)
  end
end
