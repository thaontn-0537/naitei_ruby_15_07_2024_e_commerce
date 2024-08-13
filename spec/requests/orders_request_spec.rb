require "rails_helper"

RSpec.describe "Orders", type: :request do

  describe "GET /order_info" do
    it "returns http success" do
      get "/orders/order_info"
      expect(response).to have_http_status(:success)
    end
  end

end
