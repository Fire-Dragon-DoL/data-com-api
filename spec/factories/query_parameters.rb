require 'data-com-api/query_parameters'

FactoryGirl.define do

  factory :query_parameters, class: DataComApi::QueryParameters do
    # Yes, no data required

    initialize_with { new(attributes) }
  end

end