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

    it "accepts values between 1 and 500" do
      expect{client.page_size = Random.rand(500) + 1}.not_to raise_error
    end

    it "doesn't accept values > 500" do
      expect{client.page_size = 501}.to raise_error DataComApi::ParamError
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

    describe "#all" do
      [0, 2, 4, 10, 11, 15].each do |total_contacts_count|
        context "with #{ total_contacts_count } total_hits" do
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

      it "doesn't have more records than max_size" do
        max_offset       = 10
        client.page_size = 2
        max_size         = max_offset + client.page_size
        client.stub(:max_offset).and_return(max_offset)

        DataComApiStubRequests.stub_search_contact(
          page_size:  client.page_size,
          total_hits: 25
        )

        expect(client.search_contact.all.size).to eq max_size
      end

      it "doesn't have more records than max_size when page size is odd" do
        max_offset        = 10
        client.page_size  = 3
        max_size          = max_offset - (max_offset % client.page_size)
        max_size         += client.page_size
        client.stub(:max_offset).and_return(max_offset)

        DataComApiStubRequests.stub_search_contact(
          page_size:  client.page_size,
          total_hits: 25
        )

        expect(client.search_contact.all.size).to eq max_size
      end

      it "doesn't have records when total_hits is 0" do
        DataComApiStubRequests.stub_search_contact(
          page_size:  client.page_size,
          total_hits: 0
        )

        expect(client.search_contact.all.size).to eq 0
      end
    end

    describe "#each" do
      before do
        DataComApiStubRequests.stub_search_contact(
          page_size:  client.page_size,
          total_hits: total_contacts_count
        )
      end

      let!(:total_contacts_count) { 10 }

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

    context "when starting at different offset" do

      describe "#each" do
        before do
          DataComApiStubRequests.stub_search_contact(
            page_size:  client.page_size,
            total_hits: total_contacts_count
          )
          stub_request(
            :get,
            URI.join(
              DataComApi::Client.base_uri, DataComApi::ApiURI.search_contact
            ).to_s
          ).with(
            query: hash_including({
              'offset'   => '10',
              'pageSize' => client.page_size.to_s
            })
          ).to_return(
            body: FactoryGirl.build(
              :data_com_search_contact_response,
              page_size: client.page_size,
              totalHits: total_contacts_count
            ).to_json
          )
        end

        let!(:total_contacts_count) { 10 }

        it "is an array containing all records possible for request" do
          start_at_offset = 2
          response        = client.search_contact(start_at_offset: start_at_offset)
          contacts_count  = 0

          response.each { contacts_count += 1 }
          expect(contacts_count).to eq(total_contacts_count - start_at_offset)
        end

        context "when ending at different offset" do

          it "is an array containing all records possible for request" do
            start_at_offset = 2
            # XXX: BE EXTREMELY CAREFUL, use an odd number (0 counting as 1 record)
            # otherwise test will fail because of the way I mocked web requests
            # which are returning always 2 records, even if less are returned
            end_at_offset   = 7
            contacts_count  = 0
            response        = client.search_contact(
              start_at_offset: start_at_offset,
              end_at_offset:   end_at_offset
            )

            response.each { contacts_count += 1 }
            expect(contacts_count).to eq((end_at_offset + 1) - start_at_offset)
          end

        end

      end

    end

  end

end
