require "rails_helper"

RSpec.describe "Addresses", type: :request do

  describe "GET /create" do
    it "returns http success" do
      get "/addresses/create"
      expect(response).to have_http_status(:success)
    end
  end

end
