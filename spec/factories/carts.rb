FactoryBot.define do
  factory :cart do
    user_id {user.id}
    product_id {product.id}
    quantity {rand(1..3)}
    created_at {Time.zone.now}
  end
end
