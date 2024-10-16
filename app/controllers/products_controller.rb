class ProductsController < ApplicationController
  load_and_authorize_resource only: :show
  def search
    @categories = Category.all
    @query = params[:q][:product_name_cont]
    session[:search_query] = @query
  
    if @query.present?
      search_results = Product.search(@query).results
      product_ids = search_results.map{|result| result._id}
      @products_search = Product.where(id: product_ids)
      @pagy, @products_search = pagy(@products_search, items: Settings.page_10)
      @total_results = @products_search.size
    else
      @products_search = Product.none
      @total_results = 0
    end
  
    render :search
  end

  def filter_by_category
    @categories = Category.all
    @query = session[:search_query]
    if @query.present?
      filtered_results = Product.search(
        @query,
        category_id: params[:q][:category_id_eq],
        price_gteq: params[:q][:price_gteq],
        price_lteq: params[:q][:price_lteq],
        rating_gteq: params[:q][:rating_gteq]
      ).results
      product_ids = filtered_results.map{|result| result._id}
      @products_filtered = Product.where(id: product_ids)
      @pagy, @products_filtered = pagy(@products_filtered, items: Settings.page_10)
      @total_results = @products_filtered.size
    else
      @products_filtered = Product.none
      @total_results = 0
    end
  
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
