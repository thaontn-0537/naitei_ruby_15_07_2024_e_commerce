class Feedback < ApplicationRecord
  belongs_to :user
  belongs_to :product
  belongs_to :order

  validates :rating, presence: true,
    inclusion: {in: Settings.value.rate_min..Settings.value.rate_max}
  validates :comment, length: {maximum: Settings.value.comment_length}
  has_one_attached :image

  scope :for_order_item, lambda {|user_id, order_item_id|
    where(user_id:, order_item_id:)
  }
  after_create :update_product_rating

  private

  def update_product_rating
    product.update_rating
  end

  scope :sort_by_field, lambda {|field = "updated_at", direction = "desc"|
    order(Arel.sql("#{field} #{direction}"))
  }

  scope :for_product, ->(product){where(product_id: product.id)}
end
