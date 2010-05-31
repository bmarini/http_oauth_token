if Rails.version < '3'
  ActionController::Base.send(:include, ActionController::HttpAuthentication::Token)
end

ActionController::Base.send(:include,
  ActionController::HttpAuthentication::Token::Cryptographic)