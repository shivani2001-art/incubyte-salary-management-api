require "rails_helper"

RSpec.describe JwtService do
  let(:user_id) { 1 }
  let(:payload) { { user_id: user_id } }

  describe ".encode" do
    it "returns a JWT string" do
      token = JwtService.encode(payload)
      expect(token).to be_a(String)
      expect(token.split(".").length).to eq(3)
    end
  end

  describe ".decode" do
    it "returns the payload for a valid token" do
      token = JwtService.encode(payload)
      decoded = JwtService.decode(token)
      expect(decoded[:user_id]).to eq(user_id)
    end

    it "returns nil for an expired token" do
      token = JwtService.encode(payload.merge(exp: 1.hour.ago.to_i))
      expect(JwtService.decode(token)).to be_nil
    end

    it "returns nil for an invalid token" do
      expect(JwtService.decode("invalid.token.here")).to be_nil
    end
  end
end
