require 'spec_helper'
require 'data-com-api/client'
require 'data-com-api/contact'
require 'data-com-api/responses/base'
require 'data-com-api/responses/multiple_results_base'
require 'data-com-api/responses/search_contact'

describe DataComApi::Responses::MultipleResultsBase do

  let!(:client) { FactoryGirl.build(:client) }
  subject(:multiple_results_response) do
    FactoryGirl.build(:responses_search_contact, client: client)
  end

  # Params: options, which are params passed to the request which will be
  #         converted into query params for url
  describe "#perform_request" do

    it { expect(multiple_results_response).to respond_to :perform_request }
    it { expect{multiple_results_response.send(:perform_request)}.to raise_error ArgumentError }

    it "is called when we try to access size and data is not cached" do
      client.stub(:search_contact_raw_json).and_return({ 'totalHits' => 10 })
      multiple_results_response.caching = false     
      expect(multiple_results_response).to receive(:perform_request).and_call_original

      multiple_results_response.size
    end

    it "returns correct totalHits value when size called" do
      total_size = 42
      client.stub(:search_contact_raw_json).and_return({ 'totalHits' => total_size })

      expect(multiple_results_response.size).to be total_size
    end

  end

  # Params: request, which is the requested data in json format
  describe "#transform_request" do

    it { expect(multiple_results_response).to respond_to :transform_request }
    it { expect{multiple_results_response.send(:transform_request)}.to raise_error ArgumentError }

    it "is called when we try to access page data" do
      client.stub(:search_contact_raw_json).and_return(
        FactoryGirl.build(:data_com_search_contact_response, totalHits: 10)
      )
      multiple_results_response.caching = false     
      expect(multiple_results_response).to receive(:transform_request).and_call_original

      multiple_results_response.page(1)
    end

    it "returns correct types for all records after transformation" do
      client.stub(:search_contact_raw_json).and_return(
        FactoryGirl.build(:data_com_search_contact_response, totalHits: 10)
      )
      multiple_results_response.caching = false

      multiple_results_response.page(1).each do |contact|
        expect(contact).to be_an_instance_of DataComApi::Contact
      end
    end

  end

  describe "#total_pages" do
  
    it "returns 11 pages for 32 records" do
      client.page_size = 3
      client.stub(:search_contact_raw_json).and_return(
        FactoryGirl.build(:data_com_search_contact_response, totalHits: 32)
      )

      expect(client.search_contact.total_pages).to be 11
    end
  
    it "returns 0 pages for 0 records" do
      client.page_size = 3
      client.stub(:search_contact_raw_json).and_return(
        FactoryGirl.build(:data_com_search_contact_response, totalHits: 0)
      )

      expect(client.search_contact.total_pages).to be 0
    end
  
    it "returns 1 page for 2 records" do
      client.page_size = 3
      client.stub(:search_contact_raw_json).and_return(
        FactoryGirl.build(:data_com_search_contact_response, totalHits: 2)
      )

      expect(client.search_contact.total_pages).to be 1
    end
  
    it "returns 10 pages for 30 records" do
      client.page_size = 3
      client.stub(:search_contact_raw_json).and_return(
        FactoryGirl.build(:data_com_search_contact_response, totalHits: 30)
      )

      expect(client.search_contact.total_pages).to be 10
    end
  
    it "returns #{ DataComApi::Responses::Base::MAX_OFFSET } pages for a lot of records" do
      client.page_size = 100
      client.stub(:search_contact_raw_json).and_return(
        FactoryGirl.build(
          :data_com_search_contact_response,
          totalHits: DataComApi::Responses::Base::MAX_OFFSET * client.page_size * 2
        )
      )

      expect(client.search_contact.total_pages).to be DataComApi::Responses::Base::MAX_OFFSET
    end

  end

  describe "#total_records" do
  
    it "returns 32 records for 32 records" do
      client.page_size = 3
      client.stub(:search_contact_raw_json).and_return(
        FactoryGirl.build(:data_com_search_contact_response, totalHits: 32)
      )

      expect(client.search_contact.total_records).to be 32
    end
  
    it "returns 0 records for 0 records" do
      client.page_size = 1
      client.stub(:search_contact_raw_json).and_return(
        FactoryGirl.build(:data_com_search_contact_response, totalHits: 0)
      )

      expect(client.search_contact.total_records).to be 0
    end
  
    it "returns #{ DataComApi::Responses::Base::MAX_OFFSET } * client.page_size
        records for a lot of records" do
      client.page_size = 100
      client.stub(:search_contact_raw_json).and_return(
        FactoryGirl.build(
          :data_com_search_contact_response,
          totalHits: DataComApi::Responses::Base::MAX_OFFSET * client.page_size * 2
        )
      )

      expect(client.search_contact.total_records).to be DataComApi::Responses::Base::MAX_OFFSET * client.page_size
    end

  end

end
