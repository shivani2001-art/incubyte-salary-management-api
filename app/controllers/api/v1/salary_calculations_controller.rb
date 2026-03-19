module Api
  module V1
    class SalaryCalculationsController < ApplicationController
      def show
        employee = Employee.find(params[:employee_id])
        result = SalaryCalculator.new(salary: employee.salary, country: employee.country).calculate
        render json: result, status: :ok
      end
    end
  end
end
