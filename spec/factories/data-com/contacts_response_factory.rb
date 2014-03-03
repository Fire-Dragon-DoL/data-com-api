require 'hashie'
require 'faker'

FactoryGirl.define do

  factory :data_com_contacts_response, class: Hashie::Mash do
    unrecognized              { Hashie::Mash.new('contactId' => []) }
    pointsUsed                { Faker::Number.number(2).to_i        }
    totalHits                 { Faker::Number.number(2).to_i        }
    numberOfContactsPurchased { Faker::Number.number(2).to_i        }
    pointBalance              { Faker::Number.number(4).to_i        }
    contacts                  nil

    ignore do
      contacts_size 2
    end

    initialize_with { new(attributes) }

    after(:build) do |data_com_contacts_response, evaluator|
      unless data_com_contacts_response[:contacts]
        data_com_contacts_response[:contacts] = FactoryGirl.build_list(
          :data_com_contact,
          evaluator.contacts_size
        )
      end
    end
  end

end