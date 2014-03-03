require 'uri'
require 'singleton'
require 'webmock'
require 'data-com-api/api_uri'
require 'data-com-api/client'
require 'data-com-api/query_parameters'

class DataComApiStubRequestsBase
  include Singleton
  include WebMock::API

  def stub_company_contact_count(company_id, options={})
    options = {
      total_count: 10
    }.merge!(options)

    stub_request(
      :get,
      URI.join(
        DataComApi::Client.base_uri, DataComApi::ApiURI.company_contact_count(
          company_id
        )
      ).to_s
    ).with(
      query: hash_including({})
    ).to_return(
      body: FactoryGirl.build(
        :data_com_company_contact_count_response,
        totalCount: options[:total_count]
      ).to_json
    )
  end

  def stub_search_few_contacts(options={})
    options = {
      page_size:            DataComApi::Client::BASE_PAGE_SIZE,
      total_hits:           0,
      include_size_request: true,
      size_request_only:    false,
      query:                {},
      records:              []
    }.merge!(options)

    if options[:include_size_request]
      stub_request(
        :get,
        URI.join(
          DataComApi::Client.base_uri, DataComApi::ApiURI.search_contact
        ).to_s
      ).with(
        query: hash_including(DataComApi::QueryParameters.new(
          options[:query].merge(
            page_size: DataComApi::Client::SIZE_ONLY_PAGE_SIZE,
            offset:    DataComApi::Client::BASE_OFFSET
          )
        ).to_hash)
      ).to_return(
        body: FactoryGirl.build(
          :data_com_search_contact_response,
          page_size: 0,
          totalHits: options[:total_hits],
          contacts:  []
        ).to_json
      )
    end

    unless options[:size_request_only]
      stub_request(
        :get,
        URI.join(
          DataComApi::Client.base_uri, DataComApi::ApiURI.search_contact
        ).to_s
      ).with(
        query: hash_including(DataComApi::QueryParameters.new(
          options[:query].merge(
            page_size: options[:page_size],
            offset:    DataComApi::Client::BASE_OFFSET
          )
        ).to_hash)
      ).to_return(
        body: FactoryGirl.build(
          :data_com_search_contact_response,
          # Used because we want a response with only amount of records requested
          page_size: options[:records].size,
          totalHits: options[:total_hits],
          contacts:  options[:records]
        ).to_json
      )
    end
  end

  def stub_search_contact(options={})
    options = {
      page_size:            DataComApi::Client::BASE_PAGE_SIZE,
      include_size_request: true,
      total_hits:           0,
      size_request_only:    false
    }.merge!(options)
    last_page_records = 0

    if options[:include_size_request]
      stub_request(
        :get,
        URI.join(
          DataComApi::Client.base_uri, DataComApi::ApiURI.search_contact
        ).to_s
      ).with(
        # XXX: Big webmock bug, values of hashes in query must be strings
        query: hash_including(DataComApi::QueryParameters.new(
          page_size: DataComApi::Client::SIZE_ONLY_PAGE_SIZE,
          offset:    DataComApi::Client::BASE_OFFSET
        ).to_hash)
      ).to_return(
        body: FactoryGirl.build(
          :data_com_search_contact_response,
          page_size: 0,
          totalHits: options[:total_hits]
        ).to_json
      )
    end

    if !options[:size_request_only] &&
        options[:page_size]  > 0    &&
        options[:total_hits] > 0

      total_pages       = options[:total_hits] / options[:page_size]
      last_page_records = options[:total_hits] % options[:page_size]

      total_pages.times do |page_index|
        stub_request(
          :get,
          URI.join(
            DataComApi::Client.base_uri, DataComApi::ApiURI.search_contact
          ).to_s
        ).with(
          query: hash_including(DataComApi::QueryParameters.new(
            page_size: options[:page_size],
            offset:    page_index * options[:page_size]
          ).to_hash)
        ).to_return(
          body: FactoryGirl.build(
            :data_com_search_contact_response,
            page_size: options[:page_size],
            totalHits: options[:total_hits]
          ).to_json
        )
      end
    elsif options[:total_hits] == 0 && !options[:size_request_only]
      stub_request(
        :get,
        URI.join(
          DataComApi::Client.base_uri, DataComApi::ApiURI.search_contact
        ).to_s
      ).with(
        query: hash_including(DataComApi::QueryParameters.new(
          page_size: options[:page_size],
          offset:    DataComApi::Client::BASE_OFFSET
        ).to_hash)
      ).to_return(
        body: FactoryGirl.build(
          :data_com_search_contact_response,
          page_size: 0,
          totalHits: options[:total_hits]
        ).to_json
      )      
    end

    if last_page_records > 0
      stub_request(
        :get,
        URI.join(
          DataComApi::Client.base_uri, DataComApi::ApiURI.search_contact
        ).to_s
      ).with(
        query: hash_including(DataComApi::QueryParameters.new(
          page_size: options[:page_size],
          offset:    total_pages * options[:page_size]
        ).to_hash)
      ).to_return(
        body: FactoryGirl.build(
          :data_com_search_contact_response,
          page_size: last_page_records,
          totalHits: options[:total_hits]
        ).to_json
      )
    end
  end

end

DataComApiStubRequests = DataComApiStubRequestsBase.instance