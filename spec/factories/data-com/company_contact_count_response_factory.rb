require 'hashie'
require 'faker'

FactoryGirl.define do

  # Notice that in factory I didn't care about total contacts in levels +
  # departments = totalCount
  factory :data_com_company_contact_count_response, class: Hashie::Mash do
    id          { Faker::Number.number(6).to_i }
    totalCount  { Faker::Number.number(2).to_i }
    url         { Faker::Internet.url          }
    levels      nil
    departments nil

    ignore do
      levels_size      5
      departments_size 9
    end

    initialize_with { new(attributes) }

    after(:build) do |data_com_company_contact_count_response, evaluator|
      unless data_com_company_contact_count_response[:levels]
        data_com_company_contact_count_response[:levels] = FactoryGirl.build_list(
          :data_com_company_contact_count_level,
          evaluator.levels_size
        )
      end

      unless data_com_company_contact_count_response[:departments]
        data_com_company_contact_count_response[:departments] = FactoryGirl.build_list(
          :data_com_company_contact_count_department,
          evaluator.departments_size
        )
      end
    end
  end

end