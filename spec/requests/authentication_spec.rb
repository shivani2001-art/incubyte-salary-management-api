require "rails_helper"

RSpec.describe "Authentication", type: :request do
  let!(:user) { create(:user, email: "test@example.com", password: "password123") }

  describe "POST /auth/signup" do
    context "with valid params" do
      it "creates a user and returns a token" do
        post "/auth/signup", params: { email: "new@example.com", password: "password123" }
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["token"]).to be_present
      end
    end

    context "with duplicate email" do
      it "returns 422" do
        post "/auth/signup", params: { email: "test@example.com", password: "password123" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["errors"]).to be_present
      end
    end

    context "with missing password" do
      it "returns 422" do
        post "/auth/signup", params: { email: "bad@example.com", password: "" }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "POST /auth/login" do
    context "with valid credentials" do
      it "returns a JWT token" do
        post "/auth/login", params: { email: "test@example.com", password: "password123" }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["token"]).to be_present
      end
    end

    context "with invalid password" do
      it "returns 401 unauthorized" do
        post "/auth/login", params: { email: "test@example.com", password: "wrong" }
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Invalid credentials")
      end
    end

    context "with non-existent email" do
      it "returns 401 unauthorized" do
        post "/auth/login", params: { email: "nobody@example.com", password: "password123" }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
