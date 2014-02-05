require 'active_support/core_ext/hash/reverse_merge'

module DataComApi

  class Error < StandardError

    attr_reader :http_status_code
    attr_reader :api_stack_trace
    attr_reader :error_code

    def initialize(msg=nil, options={})
      options = options.reverse_merge({
        http_status_code: nil,
        api_stack_trace:  nil,
        error_code:       nil
      })

      @http_status_code ||= options[:http_status_code] || self.class::API_HTTP_STATUS_CODE
      @api_stack_trace  ||= options[:api_stack_trace]
      @error_code       ||= options[:error_code] || self.class::API_ERROR_CODE

      super(msg)
    end

  end

  class ParamError < Error
    API_HTTP_STATUS_CODE = 400
    API_ERROR_CODE       = 'PARAM_ERROR'.freeze
  end

  class LoginFailError < Error
    API_HTTP_STATUS_CODE = 403
    API_ERROR_CODE       = 'LOGIN_FAIL'.freeze
  end

  class TokenFailError < Error
    API_HTTP_STATUS_CODE = 403
    API_ERROR_CODE       = 'TOKEN_FAIL'.freeze
  end

  class PurchaseLowPointsError < Error
    API_HTTP_STATUS_CODE = 405
    API_ERROR_CODE       = 'PURCHASE_LOW_POINTS'.freeze
  end

  class ContactNotExistError < Error
    API_HTTP_STATUS_CODE = 404
    API_ERROR_CODE       = 'CONTACT_NOT_EXIST'.freeze
  end

  class ContactNotOwnedError < Error
    API_HTTP_STATUS_CODE = 405
    API_ERROR_CODE       = 'CONTACT_NOT_OWNED'.freeze
  end

  class SearchError < Error
    API_HTTP_STATUS_CODE = 500
    API_ERROR_CODE       = 'SEARCH_ERROR'.freeze
  end

  class SysError < Error
    API_HTTP_STATUS_CODE = 500
    API_ERROR_CODE       = 'SYS_ERROR'.freeze
  end

  class NotImplementedError < Error
    API_HTTP_STATUS_CODE = 501
    API_ERROR_CODE       = 'NOT_IMPLEMENTED'.freeze
  end

  class NotAvailableError < Error
    API_HTTP_STATUS_CODE = 503
    API_ERROR_CODE       = 'NOT_AVAILABLE'.freeze
  end

end