require 'data-com-api/responses/base'

module DataComApi
  module Responses
    class SearchContact < Base

      def initialize(api_client, options={})
        @options = options
        super(api_client)
      end

      def size
        size_options = options.merge(offset: 0, page_size: 0)
        res = client.search_contact_raw_json(size_options)
        
        res['totalHits']
      end

      def each
        self.size.times do
          yield(self)
        end
      end

      def each_with_index
        index = 0
        self.each do |obj|
          yield(obj, index)
          index += 1
        end
      end

      private

        def options
          @options
        end
      
    end
  end
end