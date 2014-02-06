require 'faker'

FactoryGirl.define do

  factory :data_com_search_contact_response, class: InsensitiveHash do
    totalHits 0
    contacts []
    #     {
    #   "zip": "33316-1721",
    #   "phone": "",
    #   "areaCode": "1954",
    #   "updatedDate": "2011-07-22 08:04:25 PDT",
    #   "seoContactURL": "http://www.jigsaw.com/scid40361843/elena_tsukanova.xhtml",
    #   "state": "FL",
    #   "lastname": "Tsukanova",
    #   "firstname": "Elena",
    #   "companyName": "Moran Yacht & Ship, Inc.",
    #   "contactURL": "http://www.jigsaw.com/BC.xhtml?contactId=40361843",
    #   "contactSales": 0,
    #   "country": "United States",
    #   "owned": false,
    #   "city": "Fort Lauderdale",
    #   "title": "Ð¡harter and Yacht Management Assistant-Moscow",
    #   "contactId": 40361843,
    #   "email": "",
    #   "address": "1300 SE 17th St Ste 204",
    #   "graveyardStatus": false,
    #   "ownedType": "",
    #   "companyId": 601197
    # }

    initialize_with { new(attributes) }
  end

end