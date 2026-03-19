class Rack::Attack
  # Throttle login attempts by IP - 5 requests per 60 seconds
  throttle("auth/login", limit: 5, period: 60.seconds) do |req|
    req.ip if req.path == "/auth/login" && req.post?
  end

  # Throttle signup attempts by IP - 5 requests per 60 seconds
  throttle("auth/signup", limit: 5, period: 60.seconds) do |req|
    req.ip if req.path == "/auth/signup" && req.post?
  end

  # Throttle all API requests by IP - 100 requests per 60 seconds
  throttle("api/ip", limit: 100, period: 60.seconds) do |req|
    req.ip if req.path.start_with?("/api/")
  end

  # Return 429 with JSON body
  self.throttled_responder = lambda do |req|
    [429, { "Content-Type" => "application/json" }, [{ error: "Rate limit exceeded. Try again later." }.to_json]]
  end
end

# Use in-memory cache store for rate limiting in test
Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
