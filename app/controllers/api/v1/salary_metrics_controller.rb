module Api
  module V1
    class SalaryMetricsController < ApplicationController
      def by_country
        country = params[:country]
        return render json: { error: "country parameter is required" }, status: :bad_request if country.blank?

        employees = Employee.where(country: country)
        return render json: { error: "No employees found for country: #{country}" }, status: :not_found if employees.empty?

        render json: {
          country: country,
          min_salary: employees.minimum(:salary),
          max_salary: employees.maximum(:salary),
          avg_salary: employees.average(:salary)&.round(2),
          employee_count: employees.count
        }, status: :ok
      end

      def by_job_title
        job_title = params[:job_title]
        return render json: { error: "job_title parameter is required" }, status: :bad_request if job_title.blank?

        employees = Employee.where(job_title: job_title)
        return render json: { error: "No employees found for job title: #{job_title}" }, status: :not_found if employees.empty?

        render json: {
          job_title: job_title,
          avg_salary: employees.average(:salary)&.round(2),
          employee_count: employees.count
        }, status: :ok
      end
    end
  end
end
