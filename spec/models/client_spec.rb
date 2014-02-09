require 'spec_helper'
require 'data-com-api/responses/base'
require 'data-com-api/responses/search_contact'
require 'data-com-api/client'

describe DataComApi::Client do

  subject(:client) { FactoryGirl.build(:client) }

  it "has a valid factory" do
    expect{client}.not_to raise_error
  end

  context "env #{ described_class::ENV_NAME_TOKEN } empty" do
    before do
      @env_data_com_token                  = ENV[described_class::ENV_NAME_TOKEN]
      ENV[described_class::ENV_NAME_TOKEN] = nil
    end

    after do
      ENV[described_class::ENV_NAME_TOKEN] = @env_data_com_token
    end

    it ".new raises error when both no token passed and no env DATA_COM_TOKEN set" do
      expect{described_class.new}.to raise_error DataComApi::TokenFailError
    end

  end

  describe "#page_size=" do

    it "accepts values between 1 and 100" do
      expect{client.page_size = Random.rand(101)}.not_to raise_error
    end

    it "doesn't accept values > 100" do
      expect{client.page_size = 101}.to raise_error DataComApi::ParamError
    end

    it "doesn't accept values < 1" do
      expect{client.page_size = 0}.to raise_error DataComApi::ParamError
    end

  end

  describe "#search_contact" do

    it "returns instance of SearchContact" do
      DataComApiStubRequests.stub_search_contact 500

      expect(client.search_contact).to be_an_instance_of DataComApi::Responses::SearchContact
    end

    it "calls search_contact_raw_json on client" do
      DataComApiStubRequests.stub_search_contact 500
      expect(client).to receive(:search_contact_raw_json).once.and_call_original

      client.search_contact.size
    end

    it "has a number of pages equal to size / page_size" do
      DataComApiStubRequests.stub_search_contact 500

      search_response = client.search_contact

      expect(search_response.total_pages).to be(search_response.size / client.page_size)
    end

    it "has a number of pages not greater than #{ DataComApi::Responses::Base::MAX_OFFSET }" do
      max_pages    = DataComApi::Responses::Base::MAX_OFFSET
      # Arbitrary number bigger twice maximum amount of results that can be displayed
      max_contacts = max_pages * (client.class::MAX_PAGE_SIZE * 2)
      DataComApiStubRequests.stub_search_contact max_contacts

      search_response = client.search_contact

      expect(search_response.total_pages).to be max_pages
    end

  end

end
