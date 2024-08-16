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
    @product = Product.find_by id: params[:id]
    @cart = current_user&.carts&.find_by product_id: @product.id
    return if @product

    flash[:warning] = t "flash.not_found_product"
    redirect_to root_path
  end
end
