require "rails_helper"

RSpec.describe "Authenticated endpoints", type: :request do
  describe "without auth token" do
    it "returns 401 unauthorized" do
      get "/api/v1/employees"
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)["error"]).to eq("Unauthorized")
    end
  end

  describe "with invalid token" do
    it "returns 401 unauthorized" do
      get "/api/v1/employees", headers: { "Authorization" => "Bearer badtoken" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "with valid token" do
    let(:user) { create(:user) }

    it "allows access" do
      get "/api/v1/employees", headers: auth_headers(user)
      expect(response).not_to have_http_status(:unauthorized)
    end
  end
end
