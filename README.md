# Rails 2.3/3.0 Plugin for OAuth 2.0 Cryptographic Token authentication

This plugin backports `ActionController::HttpAuthentication::Token` and
leverages this module to give support for OAuth 2.0 Cryptographic Token
authentication.

    http://tools.ietf.org/html/draft-ietf-oauth-v2-05#section-5.3

## Warning

This plugin is not complete, and completely untested.

## Usage

    DummyController < ActionController::Base
      before_filter :oauth_authenticate
      
      private
      def oauth_authenticate
        authenticate_with_http_oauth_token do |token|
          Secret.find(token)
        end
      end
    end


## How it works

Client makes a request with an authorization header that looks something like
this (newlines for readability):

    Authorization: Token token="vF9dft4qmT",
                         nonce="s8djwd",
                         timestamp="137131200",
                         algorithm="hmac-sha256",
                         signature="wOJIO9A2W5mFwDgiDvZbTSMK/PY="

`authenticate_with_http_oauth_token` parses the authorization header, and
passes the token to the block, which is expected to return the secret
associated with this token. `authenticate_with_http_oauth_token` then uses the
secret to recalculate the signature and securely compare against the signature
passed with the request. Returns true if the signature matches, false in all
other cases.