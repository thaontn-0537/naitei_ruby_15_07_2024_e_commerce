FactoryBot.define do
  factory :product do
    association :category
    product_name { Faker::Commerce.product_name }
    description { Faker::Lorem.sentence }
    price { rand(1000..200000) }
    stock { 2 }
    sold { rand(10..50) }
    rating { rand(1..5) }
    created_at { Time.zone.now }
  end
end
