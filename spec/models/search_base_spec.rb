require 'spec_helper'
require 'data-com-api/client'
require 'data-com-api/contact'
require 'data-com-api/responses/base'
require 'data-com-api/responses/search_base'
require 'data-com-api/responses/search_contact'

describe DataComApi::Responses::SearchBase do

  let!(:client) { FactoryGirl.build(:client) }
  subject(:search_base_response) do
    FactoryGirl.build(:responses_search_contact, client: client)
  end

  # Params: options, which are params passed to the request which will be
  #         converted into query params for url
  describe "#perform_request" do

    it { expect(search_base_response).to respond_to :perform_request }
    it { expect{search_base_response.send(:perform_request)}.to raise_error ArgumentError }

    it "has correct totalHits value when size called" do
      total_size = 42
      client.stub(:search_contact_raw_json).and_return({ 'totalHits' => total_size })

      expect(search_base_response.size).to be total_size
    end

  end

  # Params: request, which is the requested data in json format
  describe "#transform_request" do

    it { expect(search_base_response).to respond_to :transform_request }
    it { expect{search_base_response.send(:transform_request)}.to raise_error ArgumentError }

    it "is called when we try to access page data" do
      client.stub(:search_contact_raw_json).and_return(
        FactoryGirl.build(:data_com_search_contact_response, totalHits: 10)
      )    
      expect(search_base_response).to receive(:transform_request).and_call_original

      search_base_response.all
    end

    it "has correct types for all records after transformation" do
      client.stub(:search_contact_raw_json).and_return(
        FactoryGirl.build(:data_com_search_contact_response, totalHits: 10)
      )

      search_base_response.each do |contact|
        expect(contact).to be_an_instance_of DataComApi::Contact
      end
    end

  end

  describe "#size" do
  
    it "has 32 records for 32 records" do
      client.page_size = 3
      client.stub(:search_contact_raw_json).and_return(
        FactoryGirl.build(:data_com_search_contact_response, totalHits: 32)
      )

      expect(client.search_contact.size).to be 32
    end
  
    it "has 0 records for 0 records" do
      client.page_size = 1
      client.stub(:search_contact_raw_json).and_return(
        FactoryGirl.build(:data_com_search_contact_response, totalHits: 0)
      )

      expect(client.search_contact.size).to be 0
    end

  end

end
