require 'hashie'
require 'active_support/core_ext/object/to_query'

class QueryParameters < Hashie::Trash
  property :companyId,        from: :company_id
  property :updatedSince,     from: :updated_since
  property :title
  property :companyName,      from: :company_name
  property :name
  property :lastname
  property :firstname
  property :email
  property :levels
  property :departments
  property :country
  property :state
  property :metroArea,        from: :metro_area
  property :areaCode,         from: :area_code
  property :zipCode,          from: :zip_code
  property :industry
  property :subIndustry,      from: :sub_industry
  property :employees
  property :revenue
  property :ownership
  property :websiteType,      from: :website_type
  property :fortuneRank,      from: :fortune_rank
  property :includeGraveyard, from: :include_graveyard
  property :order
  property :orderBy,          from: :order_by

  # Special params, used to inject into query
  property :offset
  property :pageSize, from: :page_size
  property :username
  property :password
  property :token
end