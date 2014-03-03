require 'data-com-api/responses/base'
require 'data-com-api/contact'

module DataComApi
  module Responses
    class Contacts < Base
      
      def initialize(api_client, contact_ids, username, password, purchase_flag)
        @contact_ids        = contact_ids
        @username           = username
        @password           = password
        @purchase_flag      = purchase_flag

        @used_points        = nil
        @size               = nil
        @purchased_contacts = nil
        @point_balance      = nil
        @contacts           = []
        super(api_client)
      end

      def size
        return @size if requested?

        perform_request_if_not_requested!
        @size
      end

      def used_points
        return @used_points if requested?

        perform_request_if_not_requested!
        @used_points
      end

      def purchased_contacts
        return @purchased_contacts if requested?

        perform_request_if_not_requested!
        @purchased_contacts
      end

      def point_balance
        return @point_balance if requested?

        perform_request_if_not_requested!
        @point_balance
      end

      def contacts
        return @contacts if requested?

        perform_request_if_not_requested!
        @contacts
      end

      protected

        def transform_request(request)
          @used_points        = request['pointsUsed'].to_i
          @size               = request['totalHits'].to_i
          @purchased_contacts = request['numberOfContactsPurchased'].to_i
          @point_balance      = request['pointBalance'].to_i

          if request.include? 'contacts'
            request['contacts'].each do |contact|
              @contacts << DataComApi::Contact.new(contact)
            end
          end
        end

        def perform_request
          client.contacts_raw_json(
            @contact_ids,
            @username,
            @password,
            @purchase_flag
          )
        end

      private

        def perform_request_if_not_requested!
          return if requested?

          transform_request perform_request

          @requested = true
        end

        def requested?
          @requested
        end

    end
  end
end