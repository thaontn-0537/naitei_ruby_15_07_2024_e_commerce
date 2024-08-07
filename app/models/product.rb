class Product < ApplicationRecord
  belongs_to :category
  has_many :carts, dependent: :destroy
  has_many :order_items, dependent: :nullify
  has_many :feedbacks, dependent: :destroy
  has_one_attached :image

  validates :category_id, presence: true
  validates :product_name, presence: true
  validates :price, presence: true,
    numericality: {greater_than_or_equal_to: Settings.value.min_numeric}
  validates :stock, presence: true,
    numericality: {greater_than_or_equal_to: Settings.value.min_numeric}
  validates :sold, presence: true,
    numericality: {greater_than_or_equal_to: Settings.value.min_numeric}
  validates :rating,
            numericality: {greater_than_or_equal_to: Settings.value.min_numeric,
                           less_than_or_equal_to: Settings.value.rate_max},
            allow_nil: true
end
