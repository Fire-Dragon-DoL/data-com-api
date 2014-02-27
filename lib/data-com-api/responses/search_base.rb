require 'data-com-api/responses/base'

module DataComApi
  module Responses
    # Abstract class
    class SearchBase < Base

      
      def initialize(api_client, received_options)
        @options = received_options
        super(api_client)

        # Cache pagesize, MUST NOT change between requests
        @page_size = client.page_size
      end

      def size
        return @size if @size

        size_options = options.merge(
          offset:    0,
          page_size: client.class::SIZE_ONLY_PAGE_SIZE
        )
        
        calculate_size_from_request! self.perform_request(size_options)
      end

      def at_offset(offset)          
        page_options = options.merge(
          offset:    offset,
          page_size: page_size
        )

        request = self.perform_request(page_options)
        calculate_size_from_request! request
        puts <<-eos
          offset: #{ offset }     
          page_size: #{ page_size }
          #{ request.inspect }
        eos

        self.transform_request request
      end

      # Be careful, this will load all records in memory, check total_records
      # before doing such a thing
      def all
        all_records = Array.new(self.size)

        self.each_with_index { |record, index| all_records[index] = record }

        all_records
      end

      alias_method :to_a, :all

      def each_with_index
        records_per_previous_page = page_size
        current_offset            = 0

        loop do
          binding.pry
          break if current_offset > self.real_max_offset

          records = at_offset(current_offset)

          records.each_with_index do |record, index|
            yield(record, index + current_offset)
          end

          records_per_previous_page  = records.size
          current_offset            += page_size

          break unless records_per_previous_page == page_size
        end
      end

      alias_method :each, :each_with_index

      def real_max_offset
        return @real_max_offset if @real_max_offset

        @real_max_offset = client.class::MAX_OFFSET
        @real_max_offset = @real_max_offset - (@real_max_offset % page_size)
      end

      protected

        def page_size
          @page_size
        end

        def options
          @options
        end

      private

        def calculate_size_from_request!(request)
          return if @size

          @size = request['totalHits'].to_i
        end

    end
  end
end