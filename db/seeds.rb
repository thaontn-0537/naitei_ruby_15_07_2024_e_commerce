require "faker"
require "open-uri"

# Seed Admin User
admin_user = User.create!(email: "admin@email.com",
             user_name: "Admin",
             password: "adminaccount",
             role: :admin,
             phone: "0987654322")

admin_user.image.attach(
  io: URI.open("https://picsum.photos/200/200?random=1"),
  filename: "admin_avatar.jpg",
  content_type: "image/jpeg"
)

# Seed Users
users = 15.times.map do
  user = User.create!(
    user_name: Faker::Name.name,
    email: Faker::Internet.email,
    password: "password",
    phone: "0987654321",
    created_at: DateTime.now
  )

  user.image.attach(
    io: URI.open("https://picsum.photos/200/200?random=1"),
    filename: "user_#{user.id}_image.jpg",
    content_type: "image/jpeg"
  )
  
  user
end

# Seed Addresses
users.each do |user|
  2.times do
    Address.create!(
      user_id: user.id,
      place: Faker::Address.full_address,
      default: false
    )
  end
end

# Seed Categories
10.times do |n|
  parent_id = n == 0 ? nil : n
  parent_path = parent_id.nil? ? "root" : "root/#{n-1}"
  category_name = Faker::Commerce.department

  category = Category.create!(
    parent_id: parent_id,
    parent_path: parent_path,
    category_name: category_name,
    created_at: Faker::Date.between(from: "2023-01-01", to: "2024-08-01"),
    updated_at: Faker::Date.between(from: "2023-08-01", to: "2024-08-08")
  )

  category.image.attach(
    io: URI.open("https://picsum.photos/200/200?random=1"),
    filename: "category_#{category.id}_image.jpg",
    content_type: "image/jpeg"
  )
end

# Seed Products
15.times do
  product1 = Product.create!(
    product_name: "Iphone #{rand(6..25)}",
    price: rand(1000..200000),
    stock: rand(10..50),
    description: "Iphone",
    sold: rand(100..1000),
    rating: rand(0.0..5.0).round(1),
    category_id: Category.first.id
  )

  product1.image.attach(
    io: URI.open("https://picsum.photos/200/200?random=1"),
    filename: "product_#{product1.id}_image.jpg",
    content_type: "image/jpeg"
  )
end

15.times do
  product2 = Product.create!(
    product_name: "Áo thun",
    price: rand(1000..200000),
    stock: rand(100..500),
    description: "Áo thun",
    sold: rand(100..1000),
    category_id: Category.find(2).id
  )

  product2.image.attach(
    io: URI.open("https://picsum.photos/200/200?random=1"),
    filename: "product_#{product2.id}_image.jpg",
    content_type: "image/jpeg"
  )
end

15.times do
  product3 = Product.create!(
    product_name: "Quần jean",
    price: rand(1000..200000),
    stock: rand(100..5000),
    description: "Quần jean nam",
    sold: rand(100..1000),
    rating: rand(0.0..5.0).round(1),
    category_id: Category.find(3).id
  )

  product3.image.attach(
    io: URI.open("https://picsum.photos/200/200?random=1"),
    filename: "product_#{product3.id}_image.jpg",
    content_type: "image/jpeg"
  )
end

15.times do
  product4 = Product.create!(
    product_name: "Váy",
    price: rand(1000..200000),
    stock: rand(1..20),
    description: "Váy nữ",
    sold: rand(100..1000),
    rating: rand(0.0..5.0).round(1),
    category_id: Category.find(4).id
  )

  product4.image.attach(
    io: URI.open("https://picsum.photos/200/200?random=1"),
    filename: "product_#{product4.id}_image.jpg",
    content_type: "image/jpeg"
  )
end

15.times do
  product5 = Product.create!(
    product_name: "Áo khoác",
    price: rand(1000..200000),
    stock: rand(10..50),
    description: "Áo khoác nam",
    sold: rand(100..1000),
    rating: rand(0.0..5.0).round(1),
    category_id: Category.find(5).id
  )

  product5.image.attach(
    io: URI.open("https://picsum.photos/200/200?random=1"),
    filename: "product_#{product5.id}_image.jpg",
    content_type: "image/jpeg"
  )
end

# Seed Feedback
products = Product.all

products.each do |product|
  5.times do
    feedback = Feedback.create!(
      user_id: User.pluck(:id).sample,
      product_id: product.id,
      rating: rand(1..5),
      comment: Faker::Lorem.paragraph,
      created_at: Faker::Date.between(from: 1.year.ago, to: Date.today),
      updated_at: Faker::Date.between(from: 1.year.ago, to: Date.today)
    )

    feedback.image.attach(
      io: URI.open("https://picsum.photos/200/200?random=1"),
      filename: "feedback_#{feedback.id}_image.jpg",
      content_type: "image/jpeg"
    )
  end
end

# Seed Orders
users.each do |user|
  rand(2..5).times do
    order = Order.create!(
      user_id: user.id,
      total: Faker::Number.between(from: 10_000, to: 1_000_000),
      paid_at: Faker::Date.between(from: 1.year.ago, to: Date.today),
      place: Faker::Address.full_address,
      status: rand(0..4),
      refuse_reason: Faker::Lorem.sentence
    )

    rand(1..5).times do
      product = Product.order("RAND()").limit(1).first
      order.order_items.build(
        product_id: product.id,
        quantity: rand(1..5),
        price: product.price
      )
    end
  end
end

users.each do |user|
  sampled_products = Product.pluck(:id).sample(3)
  sampled_products.each do |product_id|
    Cart.create!(
      user_id: user.id,
      product_id: product_id,
      quantity: rand(1..5)
    )
  end
end
