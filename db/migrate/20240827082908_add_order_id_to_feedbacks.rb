class AddOrderIdToFeedbacks < ActiveRecord::Migration[7.0]
  def change
    add_column :feedbacks, :order_id, :bigint
  end
end
