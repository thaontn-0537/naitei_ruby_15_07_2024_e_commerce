FactoryBot.define do
  factory :order do
    association :user
    total { rand(100..500) }
    paid_at { Time.zone.now }
    place { "HN" }
    payment_method { "momo" }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
    after(:build) do |order|
      order.user_name = order.user.user_name
      order.user_phone = order.user.phone
    end
  end
end
