# frozen_string_literal: true

require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class SolfantoOAuth2 < OmniAuth::Strategies::OAuth2
      include OmniAuth::Strategy
      
      # Give your strategy a name.
      option :name, "solfanto_oauth2"

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {
        site: Rails.env.production? ? "https://oauth2.solfanto.com" : "http://localhost:3001",
        authorize_path: "/oauth/authorize"
      }

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid { raw_info['uid'] }

      info do
        {
          email: raw_info['email']
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/oauth/token/info/me').parsed
      end
    end
  end
end
