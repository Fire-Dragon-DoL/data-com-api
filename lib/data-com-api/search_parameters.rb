require 'hashie'

class SearchParameters < Hashie::Trash
  # PARAMS_NAMES   = {
  #   company_id:        :companyId,
  #   updated_since:     :updatedSince,
  #   title:             :title,
  #   company_name:      :companyName,
  #   name:              :name,
  #   lastname:          :lastname,
  #   firstname:         :firstname,
  #   email:             :email,
  #   levels:            :levels,
  #   departments:       :departments,
  #   country:           :country,
  #   state:             :state,
  #   metro_area:        :metroArea,
  #   area_code:         :areaCode,
  #   zip_code:          :zipCode,
  #   industry:          :industry,
  #   sub_industry:      :subIndustry,
  #   employees:         :employees,
  #   revenue:           :revenue,
  #   ownership:         :ownership,
  #   website_type:      :websiteType,
  #   fortune_rank:      :fortuneRank,
  #   include_graveyard: :includeGraveyard,
  #   order:             :order,
  #   order_by:          :orderBy,
  #   offset:            :offset,
  #   page_size:         :pageSize,
  #   username:          :username,
  #   password:          :password
  # }.freeze

  property :companyId,        from: :company_id
  property :updatedSince,     from: :updated_since
  property :title,            from: :title
  property :companyName,      from: :company_name
  property :name,             from: :name
  property :lastname,         from: :lastname
  property :firstname,        from: :firstname
  property :email,            from: :email
  property :levels,           from: :levels
  property :departments,      from: :departments
  property :country,          from: :country
  property :state,            from: :state
  property :metroArea,        from: :metro_area
  property :areaCode,         from: :area_code
  property :zipCode,          from: :zip_code
  property :industry,         from: :industry
  property :subIndustry,      from: :sub_industry
  property :employees,        from: :employees
  property :revenue,          from: :revenue
  property :ownership,        from: :ownership
  property :websiteType,      from: :website_type
  property :fortuneRank,      from: :fortune_rank
  property :includeGraveyard, from: :include_graveyard
  property :order,            from: :order
  property :orderBy,          from: :order_by
  property :offset,           from: :offset
  property :pageSize,         from: :page_size

end