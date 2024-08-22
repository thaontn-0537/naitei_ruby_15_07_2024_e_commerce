module OrdersHelper
  def calculate_item_total cart
    product = Product.find_by id: cart.product_id
    cart.quantity * product.price
  end

  def calculate_total_amount order_items_ids
    order_items_ids.reduce(0) do |total_amount, id|
      cart = Cart.find_by(id:)
      total_amount + calculate_item_total(cart)
    end
  end

  def status_name status
    I18n.t("orders.statuses.#{status}")
  end

  def format_price price
    number_with_delimiter price, unit: "đ"
  end
end
