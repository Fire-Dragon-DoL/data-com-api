require 'data-com-api/contact'
require 'data-com-api/responses/search_base'
require 'data-com-api/responses/base'

module DataComApi
  module Responses
    class SearchContact < SearchBase

      protected

        def transform_request(request)
          request['contacts'].map do |contact_attributes|
            DataComApi::Contact.new(contact_attributes)
          end
        end

        def perform_request(received_options)
          client.search_contact_raw_json(received_options)
        end
      
    end
  end
end