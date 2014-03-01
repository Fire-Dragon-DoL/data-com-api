require 'spec_helper'
require 'data-com-api/query_parameters'

describe WebMock do
  let!(:dummy_url) { 'http://dummyurl.com' }

  before do
    # Be careful, when stubbing, all values must be strings
    stub_request(
      :get,
      dummy_url
    ).with(
      query: hash_including(DataComApi::QueryParameters.stringify_hash_values({
        param1: 5,
        param2: 'random1'
      }))
    ).to_return(
      body: 'body 1'
    )
  end

  it "receive a request when mocked with query param" do
    expect(
      HTTParty.get(dummy_url, {
        query: {
          param1: 5,
          param2: 'random1',
          param3: 'random3'
        }
      }).body
    ).to eq 'body 1'
  end

end
