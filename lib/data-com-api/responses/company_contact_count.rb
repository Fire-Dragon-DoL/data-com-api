require 'data-com-api/responses/base'
require 'data-com-api/company_contact_count/level'
require 'data-com-api/company_contact_count/department'

module DataComApi
  module Responses
    class CompanyContactCount < Base

      attr_reader :id
      
      def initialize(api_client, company_id, received_options)
        @options     = received_options
        @id          = company_id
        @levels      = []
        @departments = []
        @url         = nil
        @size        = nil
        @requested   = false
        super(api_client)
      end

      def size
        return @size if requested?

        perform_request_if_not_requested!
        @size
      end

      def url
        return @url if requested?

        perform_request_if_not_requested!
        @url
      end

      def levels
        return @levels if requested?

        perform_request_if_not_requested!
        @levels
      end

      def departments
        return @departments if requested?

        perform_request_if_not_requested!
        @departments
      end

      protected

        def options
          @options
        end

        def transform_request(request)
          @size = request['totalCount'].to_i
          @url  = request['url'] if request.include? 'url'

          if request.include? 'levels'
            request['levels'].each do |level|
              @levels << DataComApi::CompanyContactCount::Level.new(level)
            end
          end

          if request.include? 'departments'
            request['departments'].each do |department|
              @departments << DataComApi::CompanyContactCount::Department.new(
                department
              )
            end
          end
        end

        def perform_request(received_options)
          include_graveyard = !!received_options[:includeGraveyard]
          client.company_contact_count_raw_json(id, include_graveyard)
        end

      private

        def perform_request_if_not_requested!
          return if requested?

          transform_request perform_request(options)

          @requested = true
        end

        def requested?
          @requested
        end

    end
  end
end