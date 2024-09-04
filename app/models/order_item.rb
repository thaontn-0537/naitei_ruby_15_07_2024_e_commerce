class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true,
    numericality: {greater_than: Settings.value.min_numeric}
  validates :price, presence: true,
    numericality: {greater_than_or_equal_to: Settings.value.min_numeric}
  validate :quantity_must_not_exceed_stock

  def reviewed_by_user? user
    Feedback.exists?(user_id: user.id, product_id:)
  end

  private
  def quantity_must_not_exceed_stock
    return if product&.stock.nil?

    return unless quantity.present? && quantity > product.stock

    errors.add(:quantity)
  end
end
