class CancelOrderUpdateStockJob < ApplicationJob
  queue_as :default

  def perform order_items
    updates = []

    order_items.each do |item|
      product = Product.find_by(id: item["product_id"])
      next if product.nil?

      amount = item["quantity"]
      new_stock = product.stock.nil? ? nil : product.stock + amount
      new_sold = product.sold - amount
      product.assign_attributes(stock: new_stock, sold: new_sold)
      updates << product
    end
    Product.import updates, on_duplicate_key_update: [:stock, :sold]
  end
end
