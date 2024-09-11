require "rails_helper"

RSpec.describe Product, type: :model do
  let!(:user) { User.create(
    user_name: "User",
    email: "User@example.com",
    password: "password",
    phone: "0987654321",
    role: 0)
  }

  let!(:category1) { Category.create(category_name: "Category 1") }
  let!(:category2) { Category.create(category_name: "Category 2") }

  let!(:product1) do
    Product.create(
      category: category1,
      product_name: "Featured Product 1",
      description: "A featured product",
      price: 100,
      stock: 250,
      rating: 4.5,
      sold: 21
    )
  end
  let!(:product2) do
    Product.create(
      category: category2,
      product_name: "Featured Product 2",
      description: "Another featured product",
      price: 50,
      stock: 500,
      rating: 3.5,
      sold: 35
    )
  end
  let!(:product3) do
    Product.create(
      category: category2,
      product_name: "Non-featured Product",
      description: "This product shouldn't be featured",
      price: 20,
      stock: 192,
      rating: 0,
      sold: 8
    )
  end

  let!(:order1) { create(:order, user: user, status: 1, created_at: Time.zone.now.beginning_of_week) }
  let!(:order2) { create(:order, user: user, status: 2, created_at: Time.zone.now.beginning_of_week) }
  let!(:order3) { create(:order, user: user, status: 3, created_at: Time.zone.now.beginning_of_month) }
  let!(:order4) { create(:order, user: user, status: 4, created_at: Time.zone.now.beginning_of_month,
                  refuse_reason: "Don't like") }
  let!(:order5) { create(:order, user: user, status: 3, created_at: Time.zone.now.beginning_of_year) }
  let!(:order6) { create(:order, user: user, status: 3, created_at: 1.years.ago.beginning_of_year) }

  let!(:order_item1) { create(:order_item, order: order1, product: product1, quantity: 10) }
  let!(:order_item2) { create(:order_item, order: order1, product: product2, quantity: 5) }
  let!(:order_item3) { create(:order_item, order: order2, product: product1, quantity: 9) }
  let!(:order_item4) { create(:order_item, order: order2, product: product2, quantity: 30) }
  let!(:order_item5) { create(:order_item, order: order3, product: product3, quantity: 7) }
  let!(:order_item6) { create(:order_item, order: order4, product: product1, quantity: 6) }
  let!(:order_item7) { create(:order_item, order: order5, product: product3, quantity: 1) }
  let!(:order_item8) { create(:order_item, order: order6, product: product1, quantity: 2) }

  let!(:feedback1) { Feedback.create(user: user, order: order1, product: product1, rating: 5) }
  let!(:feedback2) { Feedback.create(user: user, order: order2, product: product1, rating: 4) }
  let!(:feedback3) { Feedback.create(user: user, order: order1, product: product2, rating: 4) }
  let!(:feedback4) { Feedback.create(user: user, order: order2, product: product2, rating: 3) }
  
  before do
    allow(Settings.featured).to receive(:rating_weight).and_return(5)
    allow(Settings.featured).to receive(:sold_weight).and_return(3)
    allow(Settings.featured).to receive(:feedback_weight).and_return(2)
  end

  describe "Associations" do
    it { should belong_to(:category) }
    it { should have_many(:carts).dependent(:destroy) }
    it { should have_many(:order_items) }
    it { should have_many(:feedbacks).dependent(:destroy) }
    it { should have_one_attached(:image) }
  end
  
  describe "Validations" do
    it { should validate_presence_of(:category_id) }

    it { should validate_presence_of(:product_name) }
    it do
      should validate_length_of(:product_name)
        .is_at_most(Settings.value.max_name)
    end

    it do
      should validate_length_of(:description)
        .is_at_most(Settings.value.max_name)
    end

    it { should validate_presence_of(:price) }
    it do
      should validate_numericality_of(:price)
        .is_greater_than_or_equal_to(Settings.value.min_numeric)
        .is_less_than_or_equal_to(Settings.value.max_numeric)
    end

    it do
      should validate_numericality_of(:stock)
        .is_greater_than_or_equal_to(Settings.value.min_numeric)
        .is_less_than_or_equal_to(Settings.value.max_numeric)
        .allow_nil
    end

    it do
      should validate_numericality_of(:rating)
        .is_greater_than_or_equal_to(Settings.value.min_numeric)
        .is_less_than_or_equal_to(Settings.value.rate_max)
        .allow_nil
    end
  end

  describe "Delegations" do
    it { should delegate_method(:category_name).to(:category).with_prefix }
  end

  describe "Scopes based on score" do
    context "Featured scope" do
      it "returns the featured products in descending order" do
        allow(Settings.featured).to receive(:min_rating).and_return(3.5)
        allow(Settings.featured).to receive(:limit).and_return(10)
  
        featured_products = Product.featured
  
        expect(featured_products).to include(product1, product2)
        expect(featured_products).not_to include(product3)
  
        expect(featured_products.first).to eq(product2)
        expect(featured_products.second).to eq(product1)
      end
    end
    
    context "Search scope" do
      it "returns products sorted by score in descending order" do
        search_products = Product.search

        expect(search_products).to include(product1, product2, product3)
        expect(search_products).to eq([product2, product1, product3])
      end
    end
  end

  describe "Find by category_id" do
    it "returns products with the specified category_ids" do
      category_ids = [category2.id]
      products = Product.by_category_ids category_ids

      expect(products).to include(product2)
      expect(products).to include(product3)
      expect(products).not_to include(product1)
    end
  end

  describe "Top selling by period" do
    context "when period is 'all_time'" do
      it "returns products sorted by total quantity sold all time" do
        top_selling_products = Product.top_selling_by_period "all_time"
        expect(top_selling_products).to include(product1, product2, product3)
        expect(top_selling_products).to eq([product2, product1, product3])

        expect(top_selling_products.first.total_quantity).to eq(35)
        expect(top_selling_products.second.total_quantity).to eq(21)
        expect(top_selling_products.third.total_quantity).to eq(8)
      end
    end

    context "when period is 'this_week'" do
      it "returns products sorted by total quantity sold this week" do
        top_selling_products = Product.top_selling_by_period("this_week")
        expect(top_selling_products).to include(product1, product2)
        expect(top_selling_products).to eq([product2, product1])

        expect(top_selling_products.first.total_quantity).to eq(35)
        expect(top_selling_products.second.total_quantity).to eq(19)
      end
    end

    context "when period is 'this_month'" do
      it "returns products sorted by total quantity sold this month" do
        top_selling_products = Product.top_selling_by_period("this_month") || 
                                Product.top_selling_by_period("invalid")

        expect(top_selling_products).to include(product1, product2, product3)
        expect(top_selling_products).to eq([product2, product1, product3])

        expect(top_selling_products.first.total_quantity).to eq(35)
        expect(top_selling_products.second.total_quantity).to eq(19)
        expect(top_selling_products.third.total_quantity).to eq(7)
      end
    end

    context "when period is 'this_year'" do
      it "returns products sorted by total quantity sold this year" do
        top_selling_products = Product.top_selling_by_period("this_year")

        expect(top_selling_products).to include(product1, product2, product3)
        expect(top_selling_products).to eq([product2, product1, product3])

        expect(top_selling_products.first.total_quantity).to eq(35)
        expect(top_selling_products.second.total_quantity).to eq(19)
        expect(top_selling_products.third.total_quantity).to eq(8)
      end
    end
  end

  describe ".ransackable_attributes" do
    it "returns the correct ransackable attributes" do
      expected_attributes = %w(
        category_id
        created_at
        description
        id
        price
        product_name
        rating
        sold
        stock
        updated_at
      )

      expect(Product.ransackable_attributes).to match_array(expected_attributes)
    end
  end

  describe ".ransackable_associations" do
    it "returns the correct ransackable associations" do
      expected_associations = %w(carts category feedbacks image_attachment image_blob order_items)

      expect(Product.ransackable_associations).to match_array(expected_associations)
    end
  end

  describe "#update_rating" do
    let!(:category) { Category.create(category_name: "Category") }
    let!(:product) do 
      Product.create(
      category: category,
      product_name: "Product",
      description: "Update product rating",
      price: 20,
      stock: 192,
      rating: 0,
      sold: 8
      )
    end

    context "when there are feedbacks" do
      let!(:order) { create(:order, user: user, status: 1, created_at: Time.zone.now.beginning_of_week) }
      let!(:feedback5) { Feedback.create(user: user, order: order, product: product, rating: 3) }
      let!(:feedback6) { Feedback.create(user: user, order: order, product: product, rating: 2) }
      let(:feedback7) { Feedback.create(user: user, order: order, product: product, rating: 3) }

      it "updates the product rating to the average of feedback ratings" do
        product.update_rating
        expect(product.rating).to eq(2.5)
      end

      it "rounds the rating to one decimal place" do
        feedback7
        product.update_rating
        expect(product.rating).to eq(2.7)
      end
    end

    context "when there are no feedbacks" do
      it "updates the product rating to 0" do
        expect(product.rating).to eq(0)
      end
    end
  end
end
