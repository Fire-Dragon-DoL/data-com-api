require 'uri'
require 'singleton'
require 'webmock'
require 'data-com-api/api_uri'
require 'data-com-api/client'
require 'data-com-api/query_parameters'

class DataComApiStubRequestsBase
  include Singleton
  include WebMock::API

  def stub_all
    stub_search_contact
  end

  def stub_search_contact(page_size, offset, total_hits)
    stub_request(
      :get,
      URI.join(
        DataComApi::Client.base_uri, DataComApi::ApiURI.search_contact
      ).to_s
    ).with(
      # XXX: Big webmock bug, if query is not a string it doesn't work
      'query' => hash_including(DataComApi::QueryParameters.new(
        page_size: 0,
        offset:    0
      ).to_hash)
    ).to_return(
      body: FactoryGirl.build(
        :data_com_search_contact_response,
        page_size: 0,
        totalHits: total_hits
      ).to_json
    )

    stub_request(
      :get,
      URI.join(
        DataComApi::Client.base_uri, DataComApi::ApiURI.search_contact
      ).to_s
    ).to_return(
      body: FactoryGirl.build(
        :data_com_search_contact_response,
        page_size: page_size,
        totalHits: total_hits
      ).to_json
    )
  end

end

DataComApiStubRequests = DataComApiStubRequestsBase.instance