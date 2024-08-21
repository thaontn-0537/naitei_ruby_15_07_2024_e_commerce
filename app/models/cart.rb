class Cart < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :quantity, presence: true,
    numericality: {greater_than: Settings.value.min_numeric}

  scope :by_id, ->(id){where(id:)}
end
