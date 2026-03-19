require "rails_helper"

RSpec.describe SalaryCalculator do
  describe "#calculate" do
    context "when country is India" do
      it "applies 10% TDS deduction" do
        result = SalaryCalculator.new(salary: 100_000, country: "India").calculate
        expect(result[:gross_salary]).to eq(100_000)
        expect(result[:deductions][:tds]).to eq(10_000.0)
        expect(result[:net_salary]).to eq(90_000.0)
      end
    end

    context "when country is United States" do
      it "applies 12% TDS deduction" do
        result = SalaryCalculator.new(salary: 100_000, country: "United States").calculate
        expect(result[:gross_salary]).to eq(100_000)
        expect(result[:deductions][:tds]).to eq(12_000.0)
        expect(result[:net_salary]).to eq(88_000.0)
      end
    end

    context "when country is Germany (other)" do
      it "applies no deductions" do
        result = SalaryCalculator.new(salary: 100_000, country: "Germany").calculate
        expect(result[:gross_salary]).to eq(100_000)
        expect(result[:deductions]).to be_empty
        expect(result[:net_salary]).to eq(100_000.0)
      end
    end

    context "case insensitive country matching" do
      it "handles lowercase india" do
        result = SalaryCalculator.new(salary: 50_000, country: "india").calculate
        expect(result[:deductions][:tds]).to eq(5_000.0)
      end

      it "handles mixed case united states" do
        result = SalaryCalculator.new(salary: 50_000, country: "UNITED STATES").calculate
        expect(result[:deductions][:tds]).to eq(6_000.0)
      end
    end

    context "decimal salary amounts" do
      it "handles decimal values correctly" do
        result = SalaryCalculator.new(salary: 55_555.55, country: "India").calculate
        expect(result[:deductions][:tds]).to eq(5_555.56)
        expect(result[:net_salary]).to eq(49_999.99)
      end
    end
  end
end
