require "rails_helper"

RSpec.describe EmployeeBlueprint do
  let(:employee) { create(:employee, full_name: "Jane Doe", job_title: "Engineer", country: "India", salary: 75_000) }

  describe ".render_as_hash" do
    it "includes the expected fields" do
      result = EmployeeBlueprint.render_as_hash(employee)
      expect(result).to include(:id, :full_name, :job_title, :country, :salary)
    end

    it "excludes timestamps" do
      result = EmployeeBlueprint.render_as_hash(employee)
      expect(result).not_to include(:created_at, :updated_at)
    end
  end
end
