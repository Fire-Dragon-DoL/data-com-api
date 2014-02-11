require 'thread/future'
require 'data-com-api/paging_maths'
require 'data-com-api/responses/base'

module DataComApi
  module Responses
    # Abstract class
    class MultipleResultsBase < Base
      
      def initialize(api_client, received_options)
        @options = received_options
        super(api_client)
        # Cache pagesize, MUST NOT change between requests
        @page_size    = client.page_size
        @paging_maths = DataComApi::PagingMaths.new(
          page_size:  page_size,
          max_offset: MAX_OFFSET
        )
      end

      def size
        result = nil
        result = cache.read(:size) if cache.exist?(:size)
        unless result
          result = cache.fetch(:size) do
            size_options = options.merge(
              offset:    0,
              page_size: client.class::SIZE_ONLY_PAGE_SIZE
            )
            
            self.perform_request(size_options)['totalHits'].to_i
          end
          paging_maths.page_size = result
        end

        result
      end

      def total_pages
        return @total_pages if @total_pages

        calculate_page_size!

        paging_maths.total_pages
      end

      # Be careful, page is 1-based
      def page(index)
        cache.fetch(index) do
          calculate_page_size!
          page_options = options.merge(
            offset: paging_maths.offset_from_page(index)
          )

          self.transform_request self.perform_request(page_options)
        end
      end

      def total_records
        return @total_records if @total_records

        calculate_page_size!

        @total_records = paging_maths.total_records
      end

      # Be careful, this will load all records in memory, check total_records
      # before doing such a thing
      def all
        cache.fetch(:all) do
          pages_count = self.total_pages
          all_records = Array.new(self.total_records)
          break all_records if pages_count == 0

          current_page      = 1
          next_page_data    = Thread.future { self.page(current_page) }
          current_page_data = nil
          current_record    = 0
          
          pages_count.times do
            current_page_data = next_page_data
            if current_page == pages_count
              next_page_data = nil
            else
              next_page_data = Thread.future { self.page(current_page + 1) }
            end

            unless current_page_data.nil?
              (~current_page_data).each do |record|
                all_records[current_record]  = record
                current_record              += 1
              end
            end

            current_page += 1
          end

          all_records
        end
      end

      alias_method :to_a, :all

      def each
        self.each_page { |current_page| current_page.each { |record| yield record } }
      end

      def each_page
        self.total_pages.times { |current_page| yield self.page(current_page + 1) }
      end

      protected

        def page_size
          @page_size
        end

        def options
          @options
        end

      private

        def calculate_page_size!
          self.size
        end

        def paging_maths
          @paging_maths
        end

    end
  end
end