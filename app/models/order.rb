class Order < ApplicationRecord
  VALID_PHONE_REGEX = Regexp.new(Settings.value.phone_format)
  ORDER_PARAMS = %i(place payment_method user_name user_phone).freeze
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
  validates :user_phone,
            length: {is: Settings.value.phone},
            format: {with: VALID_PHONE_REGEX}
  validates :status, presence: true
  validates :refuse_reason, presence: true, if: ->{status_cancelled?}
  validates :payment_method, presence: true
end
