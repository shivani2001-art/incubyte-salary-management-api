class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request!, only: [ :login, :signup ], raise: false

  def signup
    user = User.new(email: params[:email], password: params[:password])
    if user.save
      token = JwtService.encode(user_id: user.id)
      render json: { token: token }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = JwtService.encode(user_id: user.id)
      render json: { token: token }, status: :ok
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end
end
