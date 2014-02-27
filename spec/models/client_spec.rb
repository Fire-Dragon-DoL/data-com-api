require 'spec_helper'
require 'data-com-api/contact'
require 'data-com-api/responses/base'
require 'data-com-api/responses/search_contact'
require 'data-com-api/api_uri'
require 'data-com-api/client'

describe DataComApi::Client do

  subject(:client) do
    clt           = FactoryGirl.build(:client)
    clt.page_size = 2

    clt
  end

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
      expect{client.page_size = Random.rand(100) + 1}.not_to raise_error
    end

    it "doesn't accept values > 100" do
      expect{client.page_size = 101}.to raise_error DataComApi::ParamError
    end

    it "doesn't accept values < 1" do
      expect{client.page_size = 0}.to raise_error DataComApi::ParamError
    end

  end

  describe "#search_contact" do

    it "is an instance of SearchContact" do
      DataComApiStubRequests.stub_search_contact(
        page_size:  client.page_size,
        total_hits: 6
      )

      expect(client.search_contact).to be_an_instance_of DataComApi::Responses::SearchContact
    end

    it "calls search_contact_raw_json on client" do
      DataComApiStubRequests.stub_search_contact(
        page_size:  client.page_size,
        total_hits: 6
      )
      expect(client).to receive(:search_contact_raw_json).once.and_call_original

      client.search_contact.size
    end

    it "has a number of pages equal to size / page_size" do
      DataComApiStubRequests.stub_search_contact(
        page_size:  client.page_size,
        total_hits: 6
      )

      search_response = client.search_contact

      expect(search_response.total_pages).to be(search_response.size / client.page_size)
    end

    it "has a number of pages not greater than
        #{ DataComApi::Client::MAX_OFFSET / DataComApi::Client::MIN_PAGE_SIZE }" do
      client.page_size = client.class::MIN_PAGE_SIZE
      max_pages        = client.class::MAX_OFFSET
      max_pages       /= client.class::MIN_PAGE_SIZE
      # Arbitrary number bigger twice maximum amount of results that can be displayed
      total_contacts   = max_pages * (client.class::MAX_PAGE_SIZE * 2)
      DataComApiStubRequests.stub_search_contact(
        page_size:  client.page_size,
        total_hits: total_contacts
      )

      search_response = client.search_contact

      expect(search_response.total_pages).to be max_pages
    end

    it "has the last page with only few records" do
      page_index       = 2
      client.page_size = 3
      total_contacts   = 5
      records          = FactoryGirl.build(
        :data_com_search_contact_response,
        # Notice that page_size refer to real records amount returned by this page
        page_size: 2,
        offset:    3,
        totalHits: total_contacts
      )

      stub_request(
        :get,
        URI.join(
          DataComApi::Client.base_uri, DataComApi::ApiURI.search_contact
        ).to_s
      ).with(
        'query' => hash_including(DataComApi::QueryParameters.new(
          page_size: client.page_size,
          offset:    3
        ).to_hash)
      ).to_return(
        body: records.to_json
      )

      expect(client.search_contact.page(page_index).size).to be 2
    end

    # [2, 20, 49, 50, 51, 75, 100]
    [4].each do |total_contacts_count|
      describe "#all", focus: true do
        before do
          DataComApiStubRequests.stub_search_contact(
            page_size:  client.page_size,
            total_hits: total_contacts_count
          )
        end

        it "is an array containing only Contact records" do
          search_contact = client.search_contact

          search_contact.all.each do |contact|
            expect(contact).to be_an_instance_of DataComApi::Contact
          end
        end

        it "is an array containing all records possible for request" do
          expect(client.search_contact.all.size).to eq total_contacts_count
        end

      end
    end

    describe "#each", broken: true do
      let!(:total_contacts) { 10 }
      let!(:total_pages) do
        pages_count  = total_contacts / client.page_size
        pages_count += 1 unless (total_contacts % client.page_size) == 0

        pages_count
      end

      before do
        total_pages.times do |page|
          stub_request(
            :get,
            URI.join(
              DataComApi::Client.base_uri, DataComApi::ApiURI.search_contact
            ).to_s
          ).with(
            'query' => hash_including(DataComApi::QueryParameters.new(
              page_size: client.page_size,
              offset:   page * client.page_size
            ).to_hash)
          ).to_return(
            body: FactoryGirl.build(
              :data_com_search_contact_response,
              page_size: client.page_size,
              totalHits: total_contacts
            ).to_json
          )
        end
        stub_request(
          :get,
          URI.join(
            DataComApi::Client.base_uri, DataComApi::ApiURI.search_contact
          ).to_s
        ).to_return(
          body: FactoryGirl.build(
            :data_com_search_contact_response,
            page_size: client.page_size,
            totalHits: total_contacts
          ).to_json
        )
      end

      # FIXME: Both each methods have various issues with amount of repetitions
      it "yields each contact in response" do
        client.search_contact.each do |contact|
          expect(contact).to be_an_instance_of DataComApi::Contact
        end
      end

      it "yields each contact in response" do
        iterations_count = 0
        response         = client.search_contact
        response.each { iterations_count += 1 }

        expect(iterations_count).to be total_contacts
      end

    end

  end

end
