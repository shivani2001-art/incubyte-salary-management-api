module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
    attr_reader :current_user
  end

  private

  def authenticate_request!
    payload = JwtService.decode(auth_token)
    @current_user = User.find_by(id: payload&.dig(:user_id))
    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end

  def auth_token
    request.headers["Authorization"]&.split(" ")&.last
  end
end
