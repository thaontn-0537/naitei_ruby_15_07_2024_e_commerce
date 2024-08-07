class Feedback < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :rating, presence: true,
    inclusion: {in: Settings.value.rate_min..Settings.value.rate_max}
  validates :comment, length: {maximum: Settings.value.comment_length}
  has_one_attached :image
end
