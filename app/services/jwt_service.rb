class JwtService
  def self.encode(payload)
    payload = payload.dup
    payload[:exp] ||= (Time.current + JwtConfig::EXPIRATION).to_i
    JWT.encode(payload, JwtConfig::SECRET, JwtConfig::ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, JwtConfig::SECRET, true, algorithm: JwtConfig::ALGORITHM)
    HashWithIndifferentAccess.new(decoded.first)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
