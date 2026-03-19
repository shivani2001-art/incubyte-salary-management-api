require "rails_helper"

RSpec.describe "Api::V1::SalaryMetrics", type: :request do
  let(:user) { create(:user) }

  describe "GET /api/v1/salary_metrics/by_country" do
    before do
      create(:employee, country: "India", salary: 40_000)
      create(:employee, country: "India", salary: 60_000)
      create(:employee, country: "India", salary: 80_000)
      create(:employee, country: "United States", salary: 100_000)
    end

    it "returns min, max, avg salary for the given country" do
      get "/api/v1/salary_metrics/by_country", params: { country: "India" }, headers: auth_headers(user)
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["country"]).to eq("India")
      expect(body["min_salary"].to_f).to eq(40_000.0)
      expect(body["max_salary"].to_f).to eq(80_000.0)
      expect(body["avg_salary"].to_f).to eq(60_000.0)
      expect(body["employee_count"]).to eq(3)
    end

    it "returns 404 when no employees found for country" do
      get "/api/v1/salary_metrics/by_country", params: { country: "Japan" }, headers: auth_headers(user)
      expect(response).to have_http_status(:not_found)
    end

    it "returns 400 when country param is missing" do
      get "/api/v1/salary_metrics/by_country", headers: auth_headers(user)
      expect(response).to have_http_status(:bad_request)
    end

    it "returns 401 without auth" do
      get "/api/v1/salary_metrics/by_country", params: { country: "India" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/salary_metrics/by_job_title" do
    before do
      create(:employee, job_title: "Engineer", salary: 50_000)
      create(:employee, job_title: "Engineer", salary: 70_000)
      create(:employee, job_title: "Manager", salary: 90_000)
    end

    it "returns avg salary for the given job title" do
      get "/api/v1/salary_metrics/by_job_title", params: { job_title: "Engineer" }, headers: auth_headers(user)
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["job_title"]).to eq("Engineer")
      expect(body["avg_salary"].to_f).to eq(60_000.0)
      expect(body["employee_count"]).to eq(2)
    end

    it "returns 404 when no employees found for job title" do
      get "/api/v1/salary_metrics/by_job_title", params: { job_title: "CEO" }, headers: auth_headers(user)
      expect(response).to have_http_status(:not_found)
    end

    it "returns 400 when job_title param is missing" do
      get "/api/v1/salary_metrics/by_job_title", headers: auth_headers(user)
      expect(response).to have_http_status(:bad_request)
    end
  end
end
