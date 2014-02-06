module DataComApi
  module Responses
    class Base

      MAX_OFFSET = 100_000
      
      def initialize(api_client)
        @client = api_client
      end

      protected

        def get_search_contact(options={})
          response = self.class.get(
            "/rest/searchContact.json",
            generate_params(options)
          )
          increase_api_calls_count!

          response.body
        end

      private

        def client
          @client
        end

    end
  end
end