require 'data-com-api/errors'

module DataComApi

  class Client

    ENV_NAME_TOKEN = 'DATA_COM_TOKEN'.freeze
    PARAMS_NAMES   = {
      company_id:        :companyId,
      updated_since:     :updatedSince,
      title:             :title,
      company_name:      :companyName,
      name:              :name,
      lastname:          :lastname,
      firstname:         :firstname,
      email:             :email,
      levels:            :levels,
      departments:       :departments,
      country:           :country,
      state:             :state,
      metro_area:        :metroArea,
      area_code:         :areaCode,
      zip_code:          :zipCode,
      industry:          :industry,
      sub_industry:      :subIndustry,
      employees:         :employees,
      revenue:           :revenue,
      ownership:         :ownership,
      website_type:      :websiteType,
      fortune_rank:      :fortuneRank,
      include_graveyard: :includeGraveyard,
      order:             :order,
      order_by:          :orderBy,
      offset:            :offset,
      page_size:         :pageSize,
      username:          :username,
      password:          :password
    }.freeze

    def initialize(api_token=nil)
      @token = api_token || ENV[ENV_NAME_TOKEN]

      raise TokenFailError, 'No token set!' unless @token
    end

    private

      def token
        @token
      end

  end

end