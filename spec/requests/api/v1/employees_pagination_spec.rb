require "rails_helper"

RSpec.describe "Employee Pagination", type: :request do
  let(:user) { create(:user) }

  before { create_list(:employee, 30) }

  describe "GET /api/v1/employees" do
    it "returns paginated results with default page size" do
      get "/api/v1/employees", headers: auth_headers(user)
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.size).to eq(20)
    end

    it "returns second page" do
      get "/api/v1/employees", params: { page: 2 }, headers: auth_headers(user)
      body = JSON.parse(response.body)
      expect(body.size).to eq(10)
    end

    it "includes pagination headers" do
      get "/api/v1/employees", headers: auth_headers(user)
      expect(response.headers["Current-Page"]).to eq("1")
      expect(response.headers["Total-Pages"]).to be_present
      expect(response.headers["Total-Count"]).to eq("30")
    end

    it "respects per_page param" do
      get "/api/v1/employees", params: { per_page: 5 }, headers: auth_headers(user)
      body = JSON.parse(response.body)
      expect(body.size).to eq(5)
    end
  end
end
