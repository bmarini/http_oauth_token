require "test/unit"
require "openssl"
require "rubygems"
require "action_controller"
require "action_controller/http_authentication"

require File.expand_path("../lib/action_controller/http_authentication/token", File.dirname(__FILE__))
require File.expand_path("../lib/action_controller/http_authentication/token/cryptographic", File.dirname(__FILE__))

class TestCryptographicToken < Test::Unit::TestCase
  def test_it
    env = Rack::MockRequest.env_for('/resource', {
      'HTTP_AUTHORIZATION' => 'Token token="123",nonce="abc123",timestamp="1",algorithm="hmac-sha256",signature="zwz59/oC2L4OBaqfD/E4nJqpdSTREmYGwRZQVgbYbeE="'
    })
    req = ActionController::Request.new(env)
    assert ActionController::HttpAuthentication::Token::Cryptographic.authenticate(req) { |token| "abc" }
  end
end