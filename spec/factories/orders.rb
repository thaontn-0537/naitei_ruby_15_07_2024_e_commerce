FactoryBot.define do
  factory :order do
    association :user
    total { rand(100..500) }
    paid_at { Time.zone.now }
    place { "HN" }
    status { 1 }
    user_name { user.user_name }
    user_phone { user.phone }
    payment_method { "momo" }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
