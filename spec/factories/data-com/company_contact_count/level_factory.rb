require 'hashie'
require 'faker'

FactoryGirl.define do

  factory :data_com_company_contact_count_level, class: Hashie::Mash do
    count { Faker::Number.number(2).to_i }
    name  { Faker::Lorem.word            }
    url   { Faker::Internet.url          }

    initialize_with { new(attributes) }
  end

end