FactoryBot.define do
  factory :category do
    category_name { Faker::Commerce.department }
  end
end
