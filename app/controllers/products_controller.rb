class ProductsController < ApplicationController
  load_and_authorize_resource only: :show
  def search
    @categories = Category.all
    @query = params[:q][:product_name_cont]
    session[:search_query] = @query
    @products_search = if @query.blank?
                         Product.all
                       else
                         fetch_search_results(@query)
                       end
    if @products_search.present?
      @pagy, @products_search = pagy_results(@products_search)
    else
      @products_search = Product.none
    end

    @total_results = @products_search.size
    render :search
  end

  def filter_by_category
    @categories = Category.all
    @query = session[:search_query]

    if @query.present?
      @products_filtered = fetch_filtered_results(@query, params[:q])
      @pagy, @products_filtered = pagy_results(@products_filtered)
    else
      @products_filtered = Product.none
    end

    @total_results = @products_filtered.size
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

  def fetch_search_results query
    search_results = Product.search(query).results
    product_ids = search_results.map(&:_id)
    Product.where(id: product_ids)
  end

  def fetch_filtered_results query, filters
    filtered_results = Product.search(
      query,
      category_id: filters[:category_id_eq],
      price_gteq: filters[:price_gteq],
      price_lteq: filters[:price_lteq],
      rating_gteq: filters[:rating_gteq]
    ).results
    product_ids = filtered_results.map(&:_id)
    Product.where(id: product_ids)
  end

  def pagy_results products
    pagy(products, items: Settings.page_10)
  end
end
