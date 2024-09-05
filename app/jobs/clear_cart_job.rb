class ClearCartJob < ApplicationJob
  queue_as :default

  def perform cart_item_ids
    Cart.by_id(cart_item_ids).destroy_all
  end
end
