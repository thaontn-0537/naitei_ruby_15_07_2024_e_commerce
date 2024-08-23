require 'rails_helper'

RSpec.describe "Admin::Orders", type: :request do

  describe "GET /index" do
    it "returns http success" do
      get "/admin/orders/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/admin/orders/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/admin/orders/update"
      expect(response).to have_http_status(:success)
    end
  end

end
