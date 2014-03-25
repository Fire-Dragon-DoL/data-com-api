require 'httparty'
require 'json'
require 'data-com-api/errors'
require 'data-com-api/api_uri'
require 'data-com-api/responses/search_contact'
require 'data-com-api/responses/search_company'
require 'data-com-api/responses/company_contact_count'
require 'data-com-api/responses/contacts'

module DataComApi

  class Client
    include HTTParty
    base_uri 'https://www.jigsaw.com'

    ENV_NAME_TOKEN      = 'DATA_COM_TOKEN'.freeze
    TIME_ZONE           = 'Pacific Time (US & Canada)'.freeze
    BASE_OFFSET         = 0
    BASE_PAGE_SIZE      = 50
    SIZE_ONLY_PAGE_SIZE = 0
    # We start at 1, 0 is a special case
    MIN_PAGE_SIZE       = 1
    MAX_PAGE_SIZE       = 500
    MAX_OFFSET          = 100_000

    attr_reader :api_calls_count
    attr_reader :token

    def max_offset
      MAX_OFFSET
    end

    def size_only_page_size
      SIZE_ONLY_PAGE_SIZE
    end

    def initialize(api_token=nil)
      @token           = api_token || ENV[ENV_NAME_TOKEN]
      @page_size       = BASE_PAGE_SIZE
      @api_calls_count = 0

      raise TokenFailError, 'No token set!' unless @token
    end

    def page_size
      @page_size
    end

    # Page size = 0 returns objects count only (small request)
    def page_size=(value)
      real_value = value.to_i

      if real_value < MIN_PAGE_SIZE || real_value > MAX_PAGE_SIZE
        raise ParamError, <<-eos
          page_size must be between #{ MIN_PAGE_SIZE } and #{ MAX_PAGE_SIZE },
          received #{ real_value }"
        eos
      end

      @page_size = real_value
    end

    def search_contact(options={})
      Responses::SearchContact.new(self, options)
    end

    def search_company(options={})
      Responses::SearchCompany.new(self, options)
    end

    def company_contact_count(company_id, options={})
      Responses::CompanyContactCount.new(self, company_id, options)
    end

    def contacts(contact_ids, username, password, purchase_flag=false)
      Responses::Contacts.new(
        self,
        contact_ids,
        username,
        password,
        purchase_flag
      )
    end

    # Raw calls

    def company_contact_count_raw(company_id, include_graveyard)
      params = QueryParameters.new(
        token:             token,
        company_id:        company_id,
        include_graveyard: include_graveyard
      )

      response = self.class.get(
        ApiURI.company_contact_count(company_id),
        { query: params }
      )
      increase_api_calls_count!

      response.body
    end

    def search_contact_raw(options={})
      response = self.class.get(
        ApiURI.search_contact,
        generate_params(options)
      )
      increase_api_calls_count!

      response.body
    end

    def search_company_raw(options={})
      response = self.class.get(
        ApiURI.search_company,
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
        ApiURI.contacts(contact_ids),
        { query: params }
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
        ApiURI.partner_contacts(contact_ids),
        { query: params }
      )
      increase_api_calls_count!

      response.body
    end

    def partner_raw
      params = QueryParameters.new(token: token)
      
      response = self.class.get(
        ApiURI.partner,
        { query: params }
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
        ApiURI.user,
        { query: params }
      )
      increase_api_calls_count!

      response.body
    end

    # JSON calls

    def company_contact_count_raw_json(company_id, include_graveyard)
      json_or_raise company_contact_count_raw(company_id, include_graveyard)
    end

    def search_contact_raw_json(options={})
      json_or_raise search_contact_raw(options)
    end

    def search_company_raw_json(options={})
      json_or_raise search_company_raw(options)
    end

    def contacts_raw_json(contact_ids, username, password, purchase_flag=false)
      json_or_raise contacts_raw(
        contact_ids,
        username,
        password,
        purchase_flag
      )
    end

    def partner_contacts_raw_json(contact_ids, end_org_id, end_user_id)
      json_or_raise partner_contacts_raw(
        contact_ids,
        end_org_id,
        end_user_id
      )
    end

    def partner_raw_json
      json_or_raise partner_raw
    end

    def user_raw_json(username, password)
      json_or_raise user_raw(username, password)
    end

    private

      def json_or_raise(json_str)
        json = JSON.parse(json_str)

        if json.kind_of? Array
          error = json.first
          raise Error.from_code(error['errorCode']).new(error['errorMsg'])
        end

        json
      end

      def generate_params(options)
        params           = QueryParameters.new(options)
        params.offset    = BASE_OFFSET unless params.offset
        params.page_size = page_size   unless params.pageSize
        params.token     = token

        { query: params }
      end

      def increase_api_calls_count!
        @api_calls_count += 1
      end

  end

end