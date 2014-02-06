require 'httparty'
require 'json'

module DataComApi
  module Responses
    class Base
      include HTTParty
      base_uri 'https://www.jigsaw.com'
      
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

        def generate_params(options)
          # params = QueryParameters.new(
          #   options
          # )
          # .except(
          #     QueryParameters::UNALLOWED_FIELDS
          #   )

          # params.offset    = 0
          # params.page_size = client.page_size
          # params.token     = client.token

          # params

          params       = QueryParameters.new(options)
          params.token = client.token

          params
        end

        def increase_api_calls_count!
          @client.send(:increase_api_calls_count!)
        end

        def client
          @client
        end

    end
  end
end