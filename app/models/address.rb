class Address < ApplicationRecord
  belongs_to :user
  validates :place, presence: true, uniqueness: {scope: :user_id}
  validates :default, inclusion: {in: [true, false]}
end
