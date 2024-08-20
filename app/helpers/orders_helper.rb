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
end