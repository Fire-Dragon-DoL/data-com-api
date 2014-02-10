require 'thread/future'
require 'data-com-api/responses/base'

module DataComApi
  module Responses
    # Abstract class
    class MultipleResultsBase < Base

      MAX_OFFSET = 100_000
      
      def initialize(api_client, received_options)
        @options   = received_options
        super(api_client)
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

        res  = real_total_pages
        res += 1          unless (search_total_hits % page_size) == 0
        res  = MAX_OFFSET if real_total_pages > MAX_OFFSET

        res
      end

      # Be careful, page is 1-based
      def page(index)
        cache.fetch(index) do
          page_options = options.merge(
            offset: (index - 1) * page_size
          )

          self.transform_request self.perform_request(page_options)
        end
      end

      # Be careful, this will load all records in memory, check total_records
      # before doing such a thing
      def all
        cache.fetch(:all) do
          pages_count = self.total_pages
          all_records = Array.new(pages_count * self.page_size)
          break all_records if pages_count == 0

          current_page      = 1
          next_page_data    = Thread.future { self.page(current_page) }
          current_page_data = nil

          
          pages_count.times do
            current_page_data = next_page_data
            if current_page == pages_count
              next_page_data = nil
            else
              next_page_data = Thread.future { self.page(current_page + 1) }
            end

            unless current_page_data
              (~current_page_data).each do |record|
                all_records << record
              end
            end

            current_page += 1
          end

          all_records
        end
      end

      alias_method :to_a, :all

      def each
        # pages_count  = self.total_pages
        # current_page = 0
        
        # pages_count
      end

      def each_with_index
        index = 0
        self.each do |obj|
          yield(obj, index)
          index += 1
        end
      end

      protected

        def page_size
          @page_size
        end

        def options
          @options
        end

    end
  end
end