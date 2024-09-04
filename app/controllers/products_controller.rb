class ProductsController < ApplicationController
  def search
    @categories = Category.all
    @query = params[:q][:product_name_cont]
    session[:search_query] = @query
    @pagy, @products_search = pagy(
      @q.result
      .search,
      limit: Settings.page_10
    )
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
    render :search
  end

  def show
    @product = Product.find_by(id: params[:id])

    if @product
      update_product_rating
      load_feedbacks
      load_cart_for_current_user
    else
      handle_product_not_found
    end
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

  def handle_product_not_found
    flash[:warning] = t "flash.not_found_product"
    redirect_to root_path
  end
end
