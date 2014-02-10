require 'hashie'
require 'active_support/time'

module DataComApi
  class Contact < Hashie::Trash
    property :id,               from: :contactId
    property :zip
    property :phone
    property :area_code,        from: :areaCode
    property :updated_at,       from: :updatedDate,  with: ->(v) { Time.parse(v.to_s).utc }
    property :seo_contact_url,  from: :seoContactURL
    property :state
    property :first_name,       from: :firstname
    property :last_name,        from: :lastname
    property :company_name,     from: :companyName
    property :contact_url,      from: :contactURL
    property :contact_sales,    from: :contactSales
    property :country
    property :owned
    property :city
    property :title
    property :email
    property :address
    property :graveyard_status, from: :graveyardStatus
    property :owned_type,       from: :ownedType
    property :company_id,       from: :companyId

    alias_method :graveyarded,  :graveyard_status
    alias_method :graveyarded?, :graveyarded
    alias_method :owned?,       :owned
  end
end