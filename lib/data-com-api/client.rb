require 'httparty'
require 'json'
require 'data-com-api/errors'
require 'data-com-api/responses/search_contact.rb'

module DataComApi

  class Client
    include HTTParty
    base_uri 'https://www.jigsaw.com'

    ENV_NAME_TOKEN = 'DATA_COM_TOKEN'.freeze
    TIME_ZONE      = 'Pacific Time (US & Canada)'.freeze

    attr_reader :api_calls_count

    def initialize(api_token=nil)
      @token           = api_token || ENV[ENV_NAME_TOKEN]
      @page_size       = 50
      @api_calls_count = 0

      raise TokenFailError, 'No token set!' unless @token
    end

    def page_size
      @page_size
    end

    # Page size = 0 returns objects count only (small request)
    def page_size=(value)
      real_value = value.to_i

      if real_value < 0 || real_value > 100
        raise ParamError, "page_size must be between 0 and 100, received #{ real_value }"
      end

      @page_size = real_value
    end

    def search_contact(options={})
      Responses::SearchContact.new(search_contact_raw(options))
    end

    # Raw calls

    def company_contact_count_raw(company_id, include_graveyard)
      params = QueryParameters.new(
        token:             token,
        company_id:        company_id,
        include_graveyard: include_graveyard
      )

      response = self.class.get(
        "/rest/companyContactCount/#{ params.company_id }.json",
        params
      )
      increase_api_calls_count!

      response.body
    end

    def search_contact_raw(options={})
      response = self.class.get(
        "/rest/searchContact.json",
        generate_params(options)
      )
      increase_api_calls_count!

      response.body
    end

    def search_company_raw(options={})
      response = self.class.get(
        "/rest/searchCompany.json",
        generate_params(options)
      )
      increase_api_calls_count!

      response.body
    end

    def contacts_raw(contact_ids, username, password, purchase_flag=false)
      raise ParamError, 'One contact required at least' unless contact_ids.size > 0

      params = QueryParameters.new(
        token:         token,
        username:      username,
        password:      password,
        purchase_flag: purchase_flag
      )
      
      response = self.class.get(
        "/rest/contacts/#{ contact_ids.join(',') }.json",
        params
      )
      increase_api_calls_count!

      response.body
    end

    def partner_contacts_raw(contact_ids, end_org_id, end_user_id)
      raise ParamError, 'One contact required at least' unless contact_ids.size > 0

      params = QueryParameters.new(
        token:       token,
        end_org_id:  end_org_id,
        end_user_id: end_user_id
      )
      
      response = self.class.get(
        "/rest/partnerContacts/#{ contact_ids.join(',') }.json",
        params
      )
      increase_api_calls_count!

      response.body
    end

    def partner_raw
      params = QueryParameters.new(token: token)
      
      response = self.class.get(
        "/rest/partner.json",
        params
      )
      increase_api_calls_count!

      response.body
    end

    def user_raw(username, password)
      params = QueryParameters.new(
        username: username,
        password: password,
        token:    token
      )
      
      response = self.class.get(
        "/rest/user.json",
        params
      )
      increase_api_calls_count!

      response.body
    end

    private

      def token
        @token
      end

      def generate_params(options)
        params           = QueryParameters.new(options)
        params.offset    = 0 unless params.offset
        params.page_size = client.page_size unless params.page_size
        params.token     = client.token

        params
      end

      def increase_api_calls_count!
        @api_calls_count += 1
      end

  end

end