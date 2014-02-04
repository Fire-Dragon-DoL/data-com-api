require 'faker'
require 'data-com-api/client'

FactoryGirl.define do

  factory :client, class: DataComApi::Client do
    token { Faker::Internet.password }

    initialize_with { new(token) }
  end

end