module DataComApi
  module Responses
    class Base
      
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