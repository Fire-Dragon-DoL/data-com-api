require 'hashie'

module DataComApi

  module CompanyContactCount

    class Level < Hashie::Trash
      property :count
      property :name
      property :url

      alias_method :size, :count
    end

  end

end