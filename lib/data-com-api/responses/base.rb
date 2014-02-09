require 'active_support/cache'

module DataComApi
  module Responses
    class Base

      MAX_OFFSET = 100_000
      
      def initialize(api_client)
        @client        = api_client
        @cache         = ActiveSupport::Cache::MemoryStore.new
        @@null_cache ||= ActiveSupport::Cache::NullStore.new
        self.caching   = true
      end

      def caching?
        @caching
      end

      def caching=(value)
        @cache.clear if !self.caching? && value
        @caching = value
      end

      protected

        def cache
          return @cache if caching?

          @@null_cache
        end

        def client
          @client
        end

    end
  end
end