require 'spec_helper'
require 'data-com-api/client'
require 'data-com-api/responses/multiple_results_base'

describe DataComApi::Responses::MultipleResultsBase do

  let!(:client) { FactoryGirl.build(:client) }
  subject(:multiple_results_response) do
    FactoryGirl.build(:responses_search_contact, client: client)
  end

  context "#perform_request" do

    it { expect(multiple_results_response).to respond_to :perform_request }
    it { expect{multiple_results_response.send(:perform_request)}.to raise_error ArgumentError }

    it "is called when we try to access size and data is not cached" do
      client.stub(:search_contact_raw_json).and_return({ 'totalHits' => 10 })      
      expect(multiple_results_response).to receive(:perform_request).and_call_original

      multiple_results_response.size
    end

    it "returns correct totalHits value when size called" do
      total_size = 42
      client.stub(:search_contact_raw_json).and_return({ 'totalHits' => total_size })

      expect(multiple_results_response.size).to be total_size
    end

  end

end
