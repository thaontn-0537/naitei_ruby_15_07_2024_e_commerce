User.create!(email: "admin@email.com",
             user_name: "Admin",
             password: "adminaccount",
             role: :admin,
             phone: "0987654322")


users = 30.times.map do
  User.create!(
    user_name: Faker::Name.name,
    email: Faker::Internet.email,
    password: "password",
    phone: "0987654321",
    created_at: DateTime.now
  )
end

#Seed address
users.each do |user|
  2.times do
    address = Address.new(
      user: user,
      place: Faker::Address.full_address,
      default: [true, false].sample
    )
    address.save
  end
end
# Seed categories
5.times do |n|
  parent_id = n == 0 ? nil : n
  parent_path = parent_id.nil? ? "root" : "root/#{n-1}"
  category_name = Faker::Commerce.department

  Category.create!(
    parent_id: parent_id,
    parent_path: parent_path,
    category_name: category_name,
    created_at: Faker::Date.between(from: "2023-01-01", to: "2024-08-01"),
    updated_at: Faker::Date.between(from: "2023-08-01", to: "2024-08-08")
  )
end
# Seed products
30.times do
  product1 = Product.create!(product_name: "Iphone #{rand(6..25)}",
                          price: rand(1000..200000),
                          stock: rand(10..50),
                          description: "Iphone",
                          sold: rand(100..1000),
                          rating: rand(0.0..5.0).round(1),
                          category_id: Category.first.id)
end

30.times do
  product2 = Product.create!(product_name: "Áo thun",
                          price: rand(1000..200000),
                          stock: rand(100..500),
                          description: "Áo thun",
                          sold: rand(100..1000),
                          category_id: Category.find(2).id)
end
30.times do
  product3 = Product.create!(product_name: "Quần jean",
                          price: rand(1000..200000),
                          stock: rand(100..5000),
                          description: "Quần jean nam",
                          sold: rand(100..1000),
                          rating: rand(0.0..5.0).round(1),
                          category_id: Category.find(3).id)
end

30.times do
  product4 = Product.create!(product_name: "Váy",
                          price: rand(1000..200000),
                          stock: rand(1..20),
                          description: "Váy nữ",
                          sold: rand(100..1000),
                          rating: rand(0.0..5.0).round(1),
                          category_id: Category.find(4).id)
end

30.times do
  product5 = Product.create!(product_name: "Áo khoác",
                          price: rand(1000..200000),
                          stock: rand(10..50),
                          description: "Áo khoác nam",
                          sold: rand(100..1000),
                          rating: rand(0.0..5.0).round(1),
                          category_id: Category.find(5).id)
end

#Seed comments
products = Product.all

products.each do |product|
  5.times do
    Feedback.create!(
      user_id: User.pluck(:id).sample,
      product_id: product.id,
      rating: rand(1..5),
      comment: Faker::Lorem.paragraph,
      created_at: Faker::Date.between(from: 1.year.ago, to: Date.today),
      updated_at: Faker::Date.between(from: 1.year.ago, to: Date.today)
    )
  end
end
# Seed Order
users.each do |user|
  # Seed Order
  rand(2..5).times do
    order = Order.new(
      user: user,
      total: Faker::Number.between(from: 10_000, to: 1_000_000),
      paid_at: Faker::Date.between(from: 1.year.ago, to: Date.today),
      place: Faker::Address.full_address,
      status: rand(0..4),
      refuse_reason: Faker::Lorem.sentence
    )

    rand(1..5).times do
      product = Product.order("RAND()").limit(1).first
      order.order_items.build(
        product: product,
        quantity: rand(1..5),
        price: product.price
      )
    end

    order.save!
  end

  # Seed Cart
  product = Product.order("RAND()").limit(1).first
  cart = Cart.create!(
    user_id: user.id,
    product_id: product.id,
    quantity: rand(1..5)
  )
end
