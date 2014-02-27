require 'uri'
require 'singleton'
require 'webmock'
require 'data-com-api/api_uri'
require 'data-com-api/client'
require 'data-com-api/query_parameters'

class DataComApiStubRequestsBase
  include Singleton
  include WebMock::API

  def stub_search_contact(options={})
    options = {
      page_size:            DataComApi::Client::BASE_PAGE_SIZE,
      include_size_request: true,
      total_hits:           0,
      size_request_only:    false
    }.merge!(options)

    if options[:include_size_request]
      stub_request(
        :get,
        URI.join(
          DataComApi::Client.base_uri, DataComApi::ApiURI.search_contact
        ).to_s
      ).with(
        # XXX: Big webmock bug, if query is not a string it doesn't work
        'query' => hash_including(DataComApi::QueryParameters.new(
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
          'query' => hash_including(DataComApi::QueryParameters.new(
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
        # puts <<-eos
        #   query:
        #     page_size: #{ options[:page_size] }
        #     offset:    #{ page_index * options[:page_size] }

        #   body:
        #     page_size: #{ options[:page_size] }
        #     totalHits: #{ options[:total_hits] }
        # eos
      end
    end

    if last_page_records > 0
      stub_request(
        :get,
        URI.join(
          DataComApi::Client.base_uri, DataComApi::ApiURI.search_contact
        ).to_s
      ).with(
        'query' => hash_including(DataComApi::QueryParameters.new(
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