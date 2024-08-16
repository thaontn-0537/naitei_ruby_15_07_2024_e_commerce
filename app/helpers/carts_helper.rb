module CartsHelper
  def format_price price
    number_with_delimiter price, unit: "đ"
  end

  def calculate_product_price product, quantity
    product.price * quantity
  end

  def total_cart_price carts
    total_price = carts.sum do |cart|
      calculate_product_price cart.product, cart.quantity
    end
    format_price total_price
  end
end
