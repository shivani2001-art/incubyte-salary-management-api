class SalaryCalculator
  TDS_RATES = {
    "india" => 0.10,
    "united states" => 0.12
  }.freeze

  def initialize(salary:, country:)
    @salary = salary.to_d
    @country = country.to_s.strip.downcase
  end

  def calculate
    tds_rate = TDS_RATES[@country]
    deductions = {}
    total_deductions = 0

    if tds_rate
      tds_amount = (@salary * tds_rate).round(2)
      deductions[:tds] = tds_amount
      total_deductions = tds_amount
    end

    {
      gross_salary: @salary,
      deductions: deductions,
      total_deductions: total_deductions,
      net_salary: (@salary - total_deductions).round(2)
    }
  end
end
