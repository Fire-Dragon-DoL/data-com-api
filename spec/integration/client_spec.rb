require 'spec_helper'
require 'data-com-api/responses/search_contact'
require 'data-com-api/client'

describe DataComApi::Client do

  subject(:client) { FactoryGirl.build(:client) }

  describe "#search_contact" do

    it "has records when searched with no params" do
      DataComApiStubRequests.stub_search_contact(
        total_hits: 10
      )

      expect(client.search_contact.size).to be > 0
    end

    context "when searching by firstname" do
      before do
        DataComApiStubRequests.stub_search_few_contacts(
          total_hits: 1,
          query: {
            firstname: 'Dummy'
          },
          records: FactoryGirl.build_list(:data_com_contact, 1,
            firstname: 'Dummy'
          )
        )

        DataComApiStubRequests.stub_search_few_contacts(
          total_hits: 0,
          query: {
            firstname: 'DoesntExist'
          }
        )
      end

      it "with firstname Dummy it has records with Dummy as firstname" do
        expect(
          client.search_contact(firstname: 'Dummy').all.first.first_name
        ).to eq('Dummy')
      end

      it "with firstname DoesntExist it doesn't find records" do
        expect(client.search_contact(firstname: 'DoesntExist').all.first).to be_nil
      end

    end

  end

  describe "#company_contact_count" do
    before do
      DataComApiStubRequests.stub_company_contact_count(
        company_id,
        total_count: contacts_count
      )
    end

    let!(:company_id)     {  1 }
    let!(:contacts_count) { 10 }

    it { expect(client.company_contact_count(company_id).size).to eq contacts_count }
    it { expect(client.company_contact_count(company_id).url).not_to be_blank }

    it "has some levels" do
      expect(client.company_contact_count(company_id).levels).not_to be_empty
    end

    it "has some departments" do
      expect(client.company_contact_count(company_id).departments).not_to be_empty
    end

    it "doesn't have nil levels" do
      client.company_contact_count(company_id).levels.each do |level|
        expect(level).not_to be_nil
      end
    end

    it "doesn't have nil departments" do
      client.company_contact_count(company_id).departments.each do |department|
        expect(department).not_to be_nil
      end
    end

  end

end
