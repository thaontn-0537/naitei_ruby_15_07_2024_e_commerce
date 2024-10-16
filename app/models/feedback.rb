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
  after_save :update_product_index
  after_destroy :update_product_index

  private

  def update_product_rating
    product.update_rating
  end

  def update_product_index
    product.__elasticsearch__.index_document
  end

  scope :sort_by_field, lambda {|field = "updated_at", direction = "desc"|
    order(Arel.sql("#{field} #{direction}"))
  }

  scope :for_product, ->(product){where(product_id: product.id)}
end
