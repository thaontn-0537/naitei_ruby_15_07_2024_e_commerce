FactoryBot.define do
  factory :order do
    association :user
    total { 5000 }
    paid_at { Time.zone.now }
    place { "HN" }
    status { 1 }
    user_name { user.user_name }
    user_phone { user.phone }
    payment_method { "momo" }
  end
end