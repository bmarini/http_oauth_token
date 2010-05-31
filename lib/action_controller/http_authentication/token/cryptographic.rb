module ActionController
  module HttpAuthentication
    module Token

      # Handler for OAuth 2.0 Cryptographic Tokens Requests
      # http://tools.ietf.org/html/draft-ietf-oauth-v2-05#section-5.3
      module Cryptographic
        extend self

        module ControllerMethods
          def authenticate_with_http_oauth_token(&secret_procedure)
            Cryptographic.authenticate(self.request, &secret_procedure)
          end
        end

        # Usage:
        # authenticate(self.request) { |token| Secret.find(token) }
        def authenticate(request, &secret_procedure)
          token, opts = token_and_options(request)
          secret      = secret_procedure.call(token)

          return nil if [
            token, secret,
            opts[:signature], opts[:timestamp], opts[:nonce], opts[:algorithm]
          ].any? { |v| v.nil? }

          data = normalized_request_string(request, opts)
          secure_compare(
            opts[:signature], signature(opts[:algorithm], secret, data)
          )
        end

        # http://tools.ietf.org/html/draft-ietf-oauth-v2-05#section-5.3.1.2
        def normalized_request_string(request, options)
          [ options[:timestamp], options[:nonce], options[:algorithm],
            request.request_method, request.host_with_port, request.url
          ].join(',')
        end

        def signature(algorithm, secret, data)
          da = OpenSSL::Digest.const_get(algorithm.split('-').last.upcase).new
          ActiveSupport::Base64.encode64s(OpenSSL::HMAC.digest(da, secret, data))
        end

        def secure_compare(a, b)
          return false unless a.bytesize == b.bytesize
          l = a.unpack "C#{a.bytesize}"
          res = 0
          b.each_byte { |byte| res |= byte ^ l.shift }
          res == 0
        end
      end

    end
  end
end