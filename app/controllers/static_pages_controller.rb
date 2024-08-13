class StaticPagesController < ApplicationController
  before_action :get_featured_products,
                only: %i(index load_products)
  def index
    @categories = Category.all
  end

  def load_products
    respond_to do |format|
      format.js{render partial: "products/load_products", layout: false}
    end
  end

  private
  def get_featured_products
    @featured_products = Product.by_category_ids(params[:category_ids])
                                .featured
                                .distinct
  end
end
