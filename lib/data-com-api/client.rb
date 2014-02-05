require 'data-com-api/errors'

module DataComApi

  class Client

    ENV_NAME_TOKEN = 'DATA_COM_TOKEN'.freeze
    TIME_ZONE      = 'Pacific Time (US & Canada)'.freeze

    def initialize(api_token=nil)
      @token = api_token || ENV[ENV_NAME_TOKEN]

      raise TokenFailError, 'No token set!' unless @token
    end

    private

      def token
        @token
      end

  end

end