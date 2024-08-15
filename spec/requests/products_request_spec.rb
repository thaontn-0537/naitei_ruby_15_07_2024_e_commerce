require "rails_helper"

RSpec.describe "Products", type: :request do

  describe "GET /featured_products" do
    it "returns http success" do
      get "/products/featured_products"
      expect(response).to have_http_status(:success)
    end
  end

end
