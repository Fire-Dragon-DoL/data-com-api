require 'spec_helper'
require 'data-com-api/responses/search_contact'
require 'data-com-api/client'

describe DataComApi::Client do

  subject(:client) { FactoryGirl.build(:client) }

  describe "#search_contact" do

    xit "#size > 0" do
      expect(client.search_contact.size).to be > 0
    end

    xit "with first_name Dummy and returns records" do
      expect(
        client.search_contact(first_name: 'Dummy').all.first.first_name
      ).to eq('Dummy')
    end

    xit "with first_name DoesntExist and returns no records" do
      expect(client.search_contact(first_name: 'DoesntExist').all.first).to be_nil
    end

  end

end
