require 'data-com-api/company'
require 'data-com-api/responses/search_base'
require 'data-com-api/responses/base'

module DataComApi
  module Responses
    class SearchCompany < SearchBase

      MAX_PAGE_SIZE = 100

      def initialize(api_client, received_options)
        super

        @page_size = MAX_PAGE_SIZE if @page_size > MAX_PAGE_SIZE
      end

      protected

        def transform_request(request)
          request['companies'].map do |contact_attributes|
            DataComApi::Company.new(contact_attributes)
          end
        end

        def perform_request(received_options)
          client.search_company_raw_json(received_options)
        end
      
    end
  end
end