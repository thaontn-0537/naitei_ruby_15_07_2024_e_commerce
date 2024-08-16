class CartsController < ApplicationController
  def index
    @pagy, @carts = pagy(
      current_user.carts.includes(:product),
      items: Settings.page_10
    )
  end
end
