require 'data-com-api/responses/base'

module DataComApi
  module Responses
    class SearchContact < Base

      def initialize(api_client, options={})
        @options = options
        super(api_client)
      end

      def size
        50
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