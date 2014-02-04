module DataComApi

  class Error < StandardError
  end

  class ParamError < Error
  end

  class LoginFailError < Error
  end

  class TokenFailError < Error
  end

  class PurchaseLowPointsError < Error
  end

  class ContactNotExistError < Error
  end

  class ContactNotOwnedError < Error
  end

  class SearchError < Error
  end

  class SysError < Error
  end

  class NotImplementedError < Error
  end

  class NotAvailableError < Error
  end

end