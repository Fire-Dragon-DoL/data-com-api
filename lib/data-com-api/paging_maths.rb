require 'active_support/cache'

module DataComApi

  class PagingMaths

    attr_reader :page_size
    attr_reader :max_offset
    attr_reader :total_records

    def initialize(options={})
      options = {
        page_size:     50,
        total_records: 100_000,
        max_offset:    1_000_000  
      }.merge(options)

      @cache         = ActiveSupport::Cache::MemoryStore.new
      @page_size     = options[:page_size]
      @max_offset    = options[:max_offset]
      @total_records = options[:total_records]
    end

    # Fields

    def page_size=(value)
      @page_size = value
      cache.clear
    end

    def max_offset=(value)
      @max_offset = value
      cache.clear
    end

    def total_records=(value)
      @total_records = value
      cache.clear
    end

    def real_max_offset
      cache.fetch(:real_max_offset) do
        self.max_offset - (self.max_offset % self.page_size)
      end
    end

    # Methods

    def any_record?
      cache.fetch(:any_record?) do
        self.page_size > 0 && self.max_offset > 0 && self.total_records > 0
      end
    end

    def total_pages
      cache.fetch(:total_pages) do
        next 0 unless any_record?

        records_amount = self.total_records
        if self.total_records > self.real_max_offset
          records_amount = self.real_max_offset
        end

        res = records_amount / self.page_size
        res = 1 if self.total_records < self.page_size

        res
      end
    end

    def page_index(page)
      return nil unless self.any_record?

      page = case page
      when :first then 1
      when :last  then self.total_pages
      else page.to_i
      end

      cache_page = :"page_index_#{ page }"
      return cache.read(cache_page) if cache.exist? cache_page

      case page
      when 0   then page = nil
      when nil then page = nil
      else
        page = nil if page > self.total_pages
      end

      cache.write(cache_page, page)
      page
    end

    def page_from_offset(value)
      return nil unless self.any_record?

      cache_page = :"page_from_offset_#{ value }"
      return cache.read(cache_page) if cache.exist? cache_page

      page = nil

      unless value > self.max_offset
        page  = value / self.page_size
        page += 1   unless (value % self.page_size) == 0
        page += 1   if value == 0
        page  = nil if value > self.real_max_offset
      end

      cache.write(cache_page, page)
      page
    end

    def offset_from_page(value)
      return nil unless self.any_record?

      cache_page = :"offset_from_page_#{ value }"
      return cache.read(cache_page) if cache.exist? cache_page

      page = self.page_index(value)

      # This happens when page > total_pages
      if page.nil?
        cache.write(cache_page, nil)
        return nil
      end

      offset = (value - 1) * self.page_size
      offset = self.real_max_offset if page == self.total_pages

      cache.write(cache_page, offset)
      offset
    end

    def records_per_page(page)
      cache_page = :"records_per_page#{ page }"
      cache.fetch(cache_page) do
        page = self.page_index(page)

        next nil if page.nil?

        if page == self.total_pages
          records_count = self.page_size * self.total_pages
          if records_count > self.total_records
            records_count = records_count - self.total_records
          else
            self.page_size
          end
        else
          self.page_size
        end
      end
    end

    private

      def cache
        @cache
      end

  end

end