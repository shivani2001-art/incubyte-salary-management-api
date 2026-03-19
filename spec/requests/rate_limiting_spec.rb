require "rails_helper"

RSpec.describe "Rate Limiting", type: :request do
  before do
    Rack::Attack.enabled = true
    Rack::Attack.reset!
  end

  after do
    Rack::Attack.enabled = false
  end

  describe "login endpoint throttling" do
    it "allows requests under the limit" do
      5.times do
        post "/auth/login", params: { email: "test@example.com", password: "wrong" }
      end
      expect(response).to have_http_status(:unauthorized)
    end

    it "blocks requests over the limit" do
      6.times do
        post "/auth/login", params: { email: "test@example.com", password: "wrong" }
      end
      expect(response).to have_http_status(:too_many_requests)
    end
  end

  describe "signup endpoint throttling" do
    it "blocks excessive signup attempts" do
      6.times do |i|
        post "/auth/signup", params: { email: "user#{i}@test.com", password: "pass" }
      end
      expect(response).to have_http_status(:too_many_requests)
    end
  end
end
