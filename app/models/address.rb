class Address < ApplicationRecord
  ADDRESS_PARAMS = %i(place default).freeze
  belongs_to :user
  validates :place, presence: true, uniqueness: {scope: :user_id}
  validates :default, inclusion: {in: [true, false]}

  scope :sort_by_time, ->{order(created_at: :desc)}
  scope :default_or_latest, ->{find_by(default: true) || sort_by_time.first}
end
