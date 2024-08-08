class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  enum status: {
    pending: 0,
    preparing: 1,
    in_transit: 2,
    delivered: 3,
    cancelled: 4
  }, _prefix: true
  validates :total, presence: true,
    numericality: {greater_than_or_equal_to: Settings.value.min_numeric}
  validates :place, presence: true
  validates :status, presence: true
  validates :refuse_reason, presence: true, if: ->{status_cancelled?}
end
