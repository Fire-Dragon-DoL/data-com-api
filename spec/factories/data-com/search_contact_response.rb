require 'hashie'
require 'faker'
require 'active_support/hash_with_indifferent_access'
require 'data-com-api/client'

FactoryGirl.define do

  factory :data_com_search_contact_response, class: Hashie::Mash do
    ignore do
      page_size 3
    end

    totalHits 0
    contacts []

    initialize_with { new(attributes) }

    after(:build) do |data_com_search_contact_response, evaluator|
      contacts_size = data_com_search_contact_response[:totalHits]
      page_size     = evaluator.page_size

      if contacts_size > 0 && page_size > 0
        page_size = contacts_size if contacts_size < page_size

        data_com_search_contact_response.contacts = FactoryGirl.build_list(
          :data_com_contact,
          page_size
        ) if contacts_size > 0
      end
    end
  end

end