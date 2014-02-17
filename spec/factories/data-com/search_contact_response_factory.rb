require 'hashie'
require 'faker'
require 'active_support/hash_with_indifferent_access'
require 'data-com-api/client'

FactoryGirl.define do

  factory :data_com_search_contact_response, class: Hashie::Mash do
    totalHits 0
    contacts  []

    ignore do
      page_size 3
    end

    initialize_with { new(attributes) }

    after(:build) do |data_com_search_contact_response, evaluator|
      if evaluator.page_size > 0
        data_com_search_contact_response[:contacts] = FactoryGirl.build_list(
          :data_com_contact,
          evaluator.page_size
        )
      end
    end
  end

end