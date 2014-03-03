require 'hashie'

module DataComApi

  module CompanyContactCount

    class Department < Hashie::Trash
      property :count
      property :name
      property :url

      alias_method :size, :count
    end

  end

end