require 'hashie'
require 'active_support/time'

module DataComApi
  class QueryParameters < Hashie::Trash
    UNALLOWED_FIELDS = [
      :offset,
      :pageSize,
      :page_size,
      :username,
      :password,
      :token
    ].freeze

    property :companyId,        from: :company_id
    property :updatedSince,     from: :updated_since, with: ->(v) do
      Time.parse(v).utc.in_time_zone(Client::TIME_ZONE)
    end
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
    property :purchaseFlag,     from: :purchase_flag
    property :endOrgId,         from: :end_org_id
    property :endUserId,        from: :end_user_id

    # Special params, used to inject into query, set only through gem
    property :offset
    property :pageSize,         from: :page_size
    property :username
    property :password
    property :token

    # Destructively convert all values using into strings
    def self.stringify_hash_values(hash)
      hash.each_pair do |key, value|
        hash[key] = value.to_s
      end
      hash
    end

    def to_hash
      self.class.stringify_hash_values(super)
    end

  end
end