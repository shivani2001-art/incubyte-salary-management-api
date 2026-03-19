module JwtConfig
  SECRET = Rails.application.credentials.secret_key_base || ENV.fetch("JWT_SECRET", "kata-dev-secret")
  ALGORITHM = "HS256"
  EXPIRATION = 24.hours.to_i
end
