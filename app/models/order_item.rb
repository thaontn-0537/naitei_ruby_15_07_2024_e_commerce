class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true,
    numericality: {greater_than: Settings.value.min_numeric}
  validates :price, presence: true,
    numericality: {greater_than_or_equal_to: Settings.value.min_numeric}
end
