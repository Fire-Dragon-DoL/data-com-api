require 'hashie'
require 'faker'
require 'active_support/hash_with_indifferent_access'
require 'data-com-api/client'

FactoryGirl.define do

  factory :data_com_search_contact_response, class: Hashie::Mash do
    totalHits 0
    contacts  []

    ignore do
      offset         0
      # page_size do
      #   base_page_size = 3


      #   base_page_size
      # end
      page_size 3
      total_contacts { page_size }
    end

    initialize_with { new(attributes) }

    after(:build) do |data_com_search_contact_response, evaluator|
      contacts_size = data_com_search_contact_response[:totalHits]
      page_size     = evaluator.page_size

      next if page_size == 0 || contacts_size == 0

      total_pages   = contacts_size / page_size
      offset        = evaluator.offset
      total_pages  += 1 unless (contacts_size % page_size) == 0

      current_page      = offset / page_size
      current_page     += 1 unless (offset % page_size) == 0
      records_per_page  = page_size
      records_per_page  = offset % page_size if current_page == total_pages
    
      data_com_search_contact_response[:contacts] = FactoryGirl.build_list(
        :data_com_contact,
        records_per_page
      ) if records_per_page > 0
    end
  end

end