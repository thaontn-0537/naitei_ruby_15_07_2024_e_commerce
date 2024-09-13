class Order < ApplicationRecord
  VALID_PHONE_REGEX = Regexp.new(Settings.value.phone_format)
  ORDER_PARAMS = %i(place payment_method user_name user_phone).freeze
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :feedbacks, dependent: :destroy

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
  scope :by_status, lambda {|status|
    if statuses.keys.include?(status.to_s)
      where(status: statuses[status])
    else
      all
    end
  }

  scope :sorted_by, lambda {|field = "status", direction = "desc"|
    order(Arel.sql("#{field} #{direction}"))
  }
  scope :with_ids, ->(ids){where(id: ids)}

  scope :recently_updated, ->{order(updated_at: :desc)}

  scope(:group_by_time_range, lambda do
    |start_time, end_time, group_method, format|
    where(created_at: start_time..end_time)
      .where.not(status: 4)
      .send(group_method, :created_at, format:, time_zone: "Asia/Ho_Chi_Minh")
      .sum(:total)
  end)

  scope(:today, lambda do
    start_of_day = Time.zone.now.beginning_of_day
    end_of_day = Time.zone.now.end_of_day
    group_by_time_range(start_of_day, end_of_day,
                        :group_by_hour_of_day, "%H:%M")
  end)

  scope(:this_week, lambda do
    start_of_week = Time.zone.now.beginning_of_week
    end_of_week = Time.zone.now.end_of_week
    group_by_time_range(start_of_week, end_of_week,
                        :group_by_day, "%d-%m")
  end)

  scope(:this_month, lambda do
    start_of_month = Time.zone.now.beginning_of_month
    end_of_month = Time.zone.now.end_of_month
    group_by_time_range(start_of_month, end_of_month,
                        :group_by_day, "%d-%m")
  end)

  scope(:last_month, lambda do
    start_of_last_month = 1.month.ago.beginning_of_month
    end_of_last_month = 1.month.ago.end_of_month
    group_by_time_range(start_of_last_month, end_of_last_month,
                        :group_by_day, "%d-%m")
  end)

  scope(:this_year, lambda do
    start_of_year = Time.zone.now.beginning_of_year
    end_of_year = Time.zone.now.end_of_year
    group_by_time_range(start_of_year, end_of_year,
                        :group_by_month, "%m-%Y")
  end)

  scope(:three_years, lambda do
    start_of_three_years_ago = 3.years.ago.beginning_of_year
    end_of_three_years_ago = Time.zone.now.end_of_year
    group_by_time_range(start_of_three_years_ago, end_of_three_years_ago,
                        :group_by_year, "%Y")
  end)

  scope(:by_period, lambda do |period|
    case period
    when "today" then today
    when "this_week" then this_week
    when "this_month" then this_month
    when "last_month" then last_month
    when "this_year" then this_year
    when "three_years" then three_years
    else
      this_month
    end
  end)

  scope :created_at_month, lambda {|month|
    where(
      created_at: month.beginning_of_month..
                  month.end_of_month
    )
  }

  def self.cal_sum_orders orders
    orders.sum(:total)
  end

  def cancel_order role:, refuse_reason:
    formatted_reason = case role
                       when :admin
                         I18n.t(
                           "orders.refuse_reason_by_admin",
                           reason: refuse_reason
                         )
                       when :user
                         I18n.t(
                           "orders.refuse_reason_by_user",
                           reason: refuse_reason
                         )
                       else
                         refuse_reason
                       end

    Order.transaction do
      CancelOrderUpdateStockJob.perform_later(order_items.as_json(
                                                only: %i(product_id quantity)
                                              ))
      update!(
        status: :cancelled,
        refuse_reason: formatted_reason
      )
    end
  rescue ActiveRecord::RecordInvalid
    error_message = I18n.t("admin.orders.orders_list.update_failed")
    errors.add(:base, error_message)
    false
  end
end
