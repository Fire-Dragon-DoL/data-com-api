require 'data-com-api/requests/base'

module DataComApi
  module Responses
    class SearchContact < Base

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
      
    end
  end
end