module Api
  module V1
    class EmployeesController < ApplicationController
      def index
        render json: [], status: :ok
      end
    end
  end
end
