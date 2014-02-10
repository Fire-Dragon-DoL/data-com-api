module DataComApi

  class PagingMaths

    attr_accessor :page_size
    attr_accessor :max_offset
    attr_accessor :total_records

    def initialize(options={})
      options = {
        page_size:     50,
        total_records: 100_000,
        max_offset:    1_000_000  
      }.merge(options)

      self.page_size     = options[:page_size]
      self.max_offset    = options[:max_offset]
      self.total_records = options[:total_records]
    end

    def any_record?
      self.page_size > 0 && self.max_offset > 0 && self.total_records > 0
    end

  end

end