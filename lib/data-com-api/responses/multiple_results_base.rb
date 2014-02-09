require 'data-com-api/responses/base'

module DataComApi
  module Responses
    # Abstract class
    class MultipleResultsBase < Base

      MAX_OFFSET = 100_000
      
      def initialize(api_client)
        super
        # Cache pagesize, MUST NOT change between requests
        @page_size = client.page_size
      end

      def size
        result = nil
        result = cache.read(1)
        result = cache.read(:size) unless result
        unless result
          result = cache.fetch(:size) do
            size_options = options.merge(
              offset:    0,
              page_size: client.class::SIZE_ONLY_PAGE_SIZE
            )
            
            self.perform_request(size_options)['totalHits'].to_i
          end
        end

        result
      end

      def total_pages
        search_total_hits = self.size
        return 0 if search_total_hits == 0

        real_total_pages = search_total_hits / page_size

        res = 1
        if real_total_pages > 0
          res = real_total_pages
        end
        res = MAX_OFFSET if real_total_pages > MAX_OFFSET

        res
      end

      # Be careful, page is 1-based
      def page(index)
        cache.fetch(index) do
          page_options = options.merge(
            offset: (index - 1) * page_size
          )

          self.perform_request(page_options)
        end
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

        def page_size
          @page_size
        end

        def options
          @options
        end

    end
  end
end