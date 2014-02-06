require 'active_support/core_ext/hash/reverse_merge'

module DataComApi

  class Error < StandardError

    API_HTTP_STATUS_CODE = 0
    API_ERROR_CODE       = 'no error code provided'

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

    def self.error_from_code(error_code_str)
      case error_code_str
      when ParamError::API_ERROR_CODE             then ParamError
      when LoginFailError::API_ERROR_CODE         then LoginFailError
      when TokenFailError::API_ERROR_CODE         then TokenFailError
      when PurchaseLowPointsError::API_ERROR_CODE then PurchaseLowPointsError
      when ContactNotExistError::API_ERROR_CODE   then ContactNotExistError
      when ContactNotOwnedError::API_ERROR_CODE   then ContactNotOwnedError
      when SearchError::API_ERROR_CODE            then SearchError
      when SysError::API_ERROR_CODE               then SysError
      when NotImplementedError::API_ERROR_CODE    then NotImplementedError
      when NotAvailableError::API_ERROR_CODE      then NotAvailableError
      else Error
      end
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