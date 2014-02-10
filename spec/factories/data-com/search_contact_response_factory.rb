require 'hashie'
require 'faker'
require 'active_support/hash_with_indifferent_access'
require 'data-com-api/client'

FactoryGirl.define do

  factory :data_com_search_contact_response, class: Hashie::Mash do
    totalHits 0
    contacts  []

    ignore do
      offset    0
      page_size 3

      # FIXME: There is something heavily wrong, offset is not page based but
      #        record based, so maximum is MAX_OFFSET + page size (100 max) and
      #        nothing more. Must be fixed in all code
      page do
        calculated_page = 0
        unless page_size == 0
          calculated_page  = offset / page_size
          calculated_page += 1 unless (offset % page_size) == 0
        end

        calculated_page
      end

      total_contacts do
        contacts_size = totalHits

        next 0 if page_size == 0 || contacts_size == 0

        total_pages  = contacts_size / page_size
        total_pages += 1 unless (contacts_size % page_size) == 0

        current_page     = page
        records_per_page = page_size
        records_per_page = contacts_size % page_size if current_page == total_pages

        # puts "records per page: #{records_per_page}"
        # puts "contacts_size: #{contacts_size}"
        # puts "page_size: #{page_size}"
        # puts "% #{ contacts_size % page_size }"
        # puts "current_page == total_pages #{ current_page } == #{ total_pages }"
        # # Issue is here, records per page is 50
        # puts total_pages.inspect
        # puts current_page.inspect
        # puts records_per_page.inspect
      
        records_per_page
      end
    end

    initialize_with { new(attributes) }

    after(:build) do |data_com_search_contact_response, evaluator|
      if evaluator.total_contacts > 0
        data_com_search_contact_response[:contacts] = FactoryGirl.build_list(
          :data_com_contact,
          evaluator.total_contacts
        )
      end
    end
  end

end