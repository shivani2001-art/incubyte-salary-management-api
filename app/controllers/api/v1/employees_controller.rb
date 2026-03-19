module Api
  module V1
    class EmployeesController < ApplicationController
      before_action :set_employee, only: %i[show update destroy]

      def index
        employees = Employee.all
        render json: EmployeeBlueprint.render(employees), status: :ok
      end

      def show
        render json: EmployeeBlueprint.render(@employee), status: :ok
      end

      def create
        employee = Employee.new(employee_params)
        if employee.save
          render json: EmployeeBlueprint.render(employee), status: :created
        else
          render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @employee.update(employee_params)
          render json: EmployeeBlueprint.render(@employee), status: :ok
        else
          render json: { errors: @employee.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @employee.destroy
        head :no_content
      end

      private

      def set_employee
        @employee = Employee.find(params[:id])
      end

      def employee_params
        params.require(:employee).permit(:full_name, :job_title, :country, :salary)
      end
    end
  end
end
