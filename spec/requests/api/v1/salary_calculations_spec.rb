require "rails_helper"

RSpec.describe "Api::V1::SalaryCalculations", type: :request do
  let(:user) { create(:user) }

  describe "GET /api/v1/employees/:id/salary" do
    let(:employee) { create(:employee, country: "India", salary: 50_000) }

    it "returns salary breakdown with deductions" do
      get "/api/v1/employees/#{employee.id}/salary", headers: auth_headers(user)
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["gross_salary"]).to eq("50000.0")
      expect(body["deductions"]["tds"]).to eq("5000.0")
      expect(body["net_salary"]).to eq("45000.0")
    end

    it "returns no deductions for other countries" do
      other = create(:employee, country: "Germany", salary: 60_000)
      get "/api/v1/employees/#{other.id}/salary", headers: auth_headers(user)
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["deductions"]).to be_empty
      expect(body["net_salary"]).to eq("60000.0")
    end

    it "returns 404 for non-existent employee" do
      get "/api/v1/employees/999/salary", headers: auth_headers(user)
      expect(response).to have_http_status(:not_found)
    end

    it "returns 401 without auth" do
      get "/api/v1/employees/#{employee.id}/salary"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
