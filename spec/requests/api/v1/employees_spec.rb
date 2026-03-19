require "rails_helper"

RSpec.describe "Api::V1::Employees", type: :request do
  let(:user) { create(:user) }
  let(:valid_params) { { employee: { full_name: "John Doe", job_title: "Engineer", country: "India", salary: 50000.00 } } }
  let(:invalid_params) { { employee: { full_name: "", job_title: "", country: "", salary: -1 } } }

  describe "GET /api/v1/employees" do
    it "returns all employees" do
      create_list(:employee, 3)
      get "/api/v1/employees", headers: auth_headers(user)
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end

    it "returns 401 without auth token" do
      get "/api/v1/employees"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/employees/:id" do
    let(:employee) { create(:employee) }

    it "returns the employee" do
      get "/api/v1/employees/#{employee.id}", headers: auth_headers(user)
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["full_name"]).to eq(employee.full_name)
    end

    it "returns 404 for non-existent employee" do
      get "/api/v1/employees/999", headers: auth_headers(user)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/employees" do
    it "creates an employee with valid params" do
      expect {
        post "/api/v1/employees", params: valid_params, headers: auth_headers(user)
      }.to change(Employee, :count).by(1)
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["full_name"]).to eq("John Doe")
    end

    it "returns 422 with invalid params" do
      post "/api/v1/employees", params: invalid_params, headers: auth_headers(user)
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to be_present
    end
  end

  describe "PUT /api/v1/employees/:id" do
    let(:employee) { create(:employee) }

    it "updates the employee" do
      put "/api/v1/employees/#{employee.id}",
        params: { employee: { full_name: "Updated Name" } },
        headers: auth_headers(user)
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["full_name"]).to eq("Updated Name")
    end

    it "returns 422 with invalid params" do
      put "/api/v1/employees/#{employee.id}",
        params: { employee: { salary: -5 } },
        headers: auth_headers(user)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 404 for non-existent employee" do
      put "/api/v1/employees/999",
        params: { employee: { full_name: "Nope" } },
        headers: auth_headers(user)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/employees/:id" do
    let!(:employee) { create(:employee) }

    it "deletes the employee" do
      expect {
        delete "/api/v1/employees/#{employee.id}", headers: auth_headers(user)
      }.to change(Employee, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 for non-existent employee" do
      delete "/api/v1/employees/999", headers: auth_headers(user)
      expect(response).to have_http_status(:not_found)
    end
  end
end
