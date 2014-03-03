require 'singleton'

module DataComApi

  class BaseApiURI
    include Singleton

    def company_contact_count(company_id)
      "/rest/companyContactCount/#{ company_id }.json"
    end

    def search_contact
      "/rest/searchContact.json"
    end

    def search_company
      "/rest/searchCompany.json"
    end

    def contacts(contact_ids)
      "/rest/contacts/#{ contact_ids.join(',') }.json"
    end

    def partner_contacts(contact_ids)
      "/rest/partnerContacts/#{ contact_ids.join(',') }.json"
    end

    def partner
      "/rest/partner.json"
    end

    def user
      "/rest/user.json"
    end
    
  end

  ApiURI = BaseApiURI.instance

end