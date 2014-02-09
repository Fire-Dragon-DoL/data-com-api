require 'data-com-api/responses/search_contact'

FactoryGirl.define do

  factory :responses_search_contact, class: DataComApi::Responses::SearchContact do
    ignore do
      client { FactoryGirl.build(:client) }
    end

    initialize_with { new(client, attributes) }
  end

end