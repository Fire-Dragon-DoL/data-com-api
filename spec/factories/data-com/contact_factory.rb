require 'hashie'
require 'faker'
require 'active_support/time'
require 'active_support/hash_with_indifferent_access'
require 'data-com-api/client'

FactoryGirl.define do

  factory :data_com_contact, class: Hashie::Mash do
    zip             { Faker::Address.zip.to_s                                  }
    phone           { Faker::PhoneNumber.phone_number                          }
    areaCode        { Faker::Number.number(3)                                  }
    updatedDate     { Time.now.utc.in_time_zone(DataComApi::Client::TIME_ZONE) }
    seoContactURL   { Faker::Internet.url                                      }
    state           { Faker::Address.state_abbr                                }
    lastname        { Faker::Name.last_name                                    }
    firstname       { Faker::Name.first_name                                   }
    companyName     { Faker::Company.name                                      }
    contactURL      { Faker::Internet.url                                      }
    contactSales    { Faker::Number.number(2).to_i                             }
    country         { Faker::Address.country                                   }
    owned           false
    city            { Faker::Address.city                                      }
    title           { Faker::Lorem.sentence                                    }
    contactId       { Faker::Number.number(6).to_i                             }
    email           { Faker::Internet.email                                    }
    address         { Faker::Address.street_address                            }
    graveyardStatus false
    ownedType       ""
    companyId       { Faker::Number.number(4)                                  }

    initialize_with { new(attributes) }
  end

end