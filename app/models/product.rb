class Product < ApplicationRecord
  acts_as_paranoid
  PRODUCT_PARAMS = %i(category_id product_name image description price
                      stock).freeze
  belongs_to :category
  has_many :carts, dependent: :destroy
  has_many :order_items # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :feedbacks, dependent: :destroy
  has_one_attached :image

  validates :category_id, presence: true
  validates :product_name, presence: true,
            length: {maximum: Settings.value.max_name}
  validates :description,
            length: {maximum: Settings.value.max_name}
  validates :price, presence: true,
            numericality: {greater_than_or_equal_to: Settings.value.min_numeric,
                           less_than_or_equal_to: Settings.value.max_numeric}
  validates :stock,
            allow_nil: true,
            numericality: {greater_than_or_equal_to: Settings.value.min_numeric,
                           less_than_or_equal_to: Settings.value.max_numeric}
  validates :rating,
            numericality: {greater_than_or_equal_to: Settings.value.min_numeric,
                           less_than_or_equal_to: Settings.value.rate_max},
            allow_nil: true

  delegate :category_name, to: :category, prefix: true

  scope(:featured, lambda do
    select(
      "products.*,
          (#{Settings.featured.rating_weight} * COALESCE(products.rating, 0) +
            #{Settings.featured.sold_weight} * COALESCE(products.sold, 0) +
            #{Settings.featured.feedback_weight} * COALESCE(
            COUNT(feedbacks.id), 0)) AS score,
          COUNT(feedbacks.id) AS feedback_count"
    )
      .joins("LEFT JOIN feedbacks ON feedbacks.product_id = products.id")
      .group("products.id")
      .having("products.rating >= #{Settings.featured.min_rating}")
      .order("score DESC")
      .limit(Settings.featured.limit)
  end)
  scope(:by_category_ids, lambda do |category_ids|
    where(category_id: category_ids) if category_ids.present?
  end)

  scope(:search, lambda do
    select(
      "products.*,
          (#{Settings.featured.rating_weight} * COALESCE(products.rating, 0) +
            #{Settings.featured.sold_weight} * COALESCE(products.sold, 0) +
            #{Settings.featured.feedback_weight} * COALESCE(
            COUNT(feedbacks.id), 0)) AS score,
          COUNT(feedbacks.id) AS feedback_count"
    )
    .joins("LEFT JOIN feedbacks ON feedbacks.product_id = products.id")
    .group("products.id")
    .having("products.rating IS NOT NULL")
    .order("score DESC")
  end)

  scope(:top_selling_by_period, lambda do |period|
    time_range = case period
                 when "all_time"
                   nil
                 when "this_week"
                   Time.zone.now.beginning_of_week..Time.zone.now.end_of_week
                 when "this_month"
                   Time.zone.now.beginning_of_month..Time.zone.now.end_of_month
                 when "this_year"
                   Time.zone.now.beginning_of_year..Time.zone.now.end_of_year
                 end

    base_query = select("products.*, SUM(order_items.quantity)
                          AS total_quantity")
                 .joins(:order_items)
                 .joins("JOIN orders ON orders.id = order_items.order_id")
                 .group("products.id")
                 .where.not(orders: {status: 4})
                 .order("total_quantity DESC")
    if time_range
      base_query.where("orders.created_at BETWEEN ? AND ?", time_range.first,
                       time_range.last)
    else
      base_query
    end
  end)

  def self.ransackable_attributes _auth_object = nil
    %w(
      category_id
      created_at
      description
      id
      price
      product_name
      rating
      sold
      stock
      updated_at
    )
  end

  def self.ransackable_associations _auth_object = nil
    %w(carts category feedbacks image_attachment image_blob order_items)
  end

  def increment stock_amount: 0, sold_amount: 0
    self.stock += stock_amount
    self.sold += sold_amount
    save!
  end

  def update_rating
    if feedbacks.any?
      average_rating = feedbacks.average(:rating).to_f
      rounded_rating = average_rating.round(1)
      update(rating: rounded_rating)
    else
      update(rating: 0)
    end
  end
end
