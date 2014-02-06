module DataComApi
  module Responses
    class Base

      MAX_OFFSET = 100_000
      
      def initialize(api_client)
        @client = api_client
      end

      protected

        def client
          @client
        end

    end
  end
end