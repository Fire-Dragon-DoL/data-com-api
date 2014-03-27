require 'spec_helper'
require 'faker'
require 'data-com-api/responses/search_contact'
require 'data-com-api/responses/search_company'
require 'data-com-api/responses/company_contact_count'
require 'data-com-api/responses/contacts'
require 'data-com-api/client'
require 'data-com-api/company_contact_count/department'
require 'data-com-api/company_contact_count/level'
require 'data-com-api/contact'
require 'data-com-api/errors'

describe DataComApi::Client do

  subject(:client) { FactoryGirl.build(:client) }

  describe "#search_contact" do

    it "raises ApiLimitExceededError when API limit exceeded text is returned" do
      stub_request(
        :get,
        URI.join(
          DataComApi::Client.base_uri, DataComApi::ApiURI.search_contact
        ).to_s
      ).with(query: hash_including({})).to_return(
        body: DataComApi::Error::API_LIMIT_EXCEEDED_MSG
      )

      expect{
        client.search_contact.size
      }.to raise_error DataComApi::ApiLimitExceededError
    end

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
        expect(level).to be_an_instance_of DataComApi::CompanyContactCount::Level
      end
    end

    it "doesn't have nil departments" do
      client.company_contact_count(company_id).departments.each do |department|
        expect(department).to be_an_instance_of DataComApi::CompanyContactCount::Department
      end
    end

  end

  describe "#contact" do
    before do
      DataComApiStubRequests.stub_contacts(
        contact_ids,
        username:           username,
        password:           password,
        purchase_flag:      purchase_flag,
        total_hits:         total_hits,
        used_points:        used_points,
        purchased_contacts: purchased_contacts,
        point_balance:      point_balance
      )
    end

    let!(:contact_ids)        { [1, 2]                    }
    let!(:username)           { Faker::Internet.user_name }
    let!(:password)           { Faker::Internet.password  }
    let!(:purchase_flag)      { false                     }
    let!(:total_hits)         { 1                         }
    let!(:used_points)        { 2000                      }
    let!(:purchased_contacts) { 1                         }
    let!(:point_balance)      { 4818                      }

    it "has used some points" do
      expect(
        client.contacts(contact_ids, username, password, purchase_flag).used_points
      ).to be > 0
    end

    it "has found some records" do
      expect(
        client.contacts(contact_ids, username, password, purchase_flag).size
      ).to eq total_hits
    end

    it "has purchased some contacts" do
      expect(
        client.contacts(contact_ids, username, password, purchase_flag).purchased_contacts
      ).to eq purchased_contacts
    end

    it "reports new point balance" do
      expect(
        client.contacts(contact_ids, username, password, purchase_flag).point_balance
      ).to eq point_balance
    end

    it "has some contacts" do
      expect(
        client.contacts(
          contact_ids,
          username,
          password,
          purchase_flag
        ).contacts
      ).not_to be_empty
    end

    it "doesn't have nil contacts" do
      client.contacts(
        contact_ids,
        username,
        password,
        purchase_flag
      ).contacts.each do |contact|
        expect(contact).to be_an_instance_of DataComApi::Contact
      end
    end

  end

end
