module Sorcery
  module Providers
    class KeycloakOpenid < Base
      attr_accessor :key, :secret, :callback_url, :user_info_path

      def get_user_hash(access_token)
        user_hash = {}
        user_hash[:user_info] = JSON.parse(open(user_info_path, 'Authorization' => "Bearer #{access_token.token}").read)
        user_hash[:uid] = user_hash[:user_info]['sub']
        user_hash
      end

      def login_url(params, session)
        client.auth_code.authorize_url(redirect_uri: callback_url, scope: 'openid')
      end

      def process_callback(params, session)
        client.auth_code.get_token(params[:code], redirect_uri: callback_url)
      end

      def get_access_token
        client.client_credentials.get_token
      end

      private

      def client
        @client ||= OAuth2::Client.new(
          'geocmsapp',
          'BKXllvPcvqOID2sh2i1Myt3Ah9VXvJYJ',
          site: 'http://keycloak:8080',
          authorize_url: 'http://keycloak:8080/realms/geocms/protocol/openid-connect/auth',
          token_url: 'http://keycloak:8080/realms/geocms/protocol/openid-connect/token'
        )
      end
    end
  end
end