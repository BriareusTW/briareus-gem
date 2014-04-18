# 帳號系統 API 名稱空間
module Briareus::Torii
  SERVER_VERSION = 0x00
  REQUIRE_TORII_CRL = 0x0f

  LOGIN = 0x10
  CHANGE_PASSWORD = 0x11
  CHANGE_USERNAME = 0x12
  RESET_PASSWORD = 0x1f

  GET_ACCOUNT_PROFILE = 0x20
  SET_ACCOUNT_PROFILE = 0x21
  QUERY_USERNAME = 0x2f

  CREATE_ACCOUNT = 0x30

  VALIDATE_TICKET = 0xf0
  AUDIT_QUERY = 0xf1

  autoload :Client, 'briareus/torii/client'
  autoload :Ticket, 'briareus/torii/ticket'

  # Input example:
  #   mixing_salt("1234567890", "ABC") => "1A2B3C4A5B6C7A8B9C0A"
  #   mixing_salt("123", "ABCDEFGHIJ") => "1A2B3C1D2E3F1G2H3I1J"
  def self.mixing_salt(base, salt)
    if base.length > salt.length
      salt = salt * (base.length/salt.length + 1)
      bound = base.length
    else
      base = base * (salt.length/base.length + 1)
      bound = salt.length
    end

    mixed_string = "\0" * (bound*2)
    bound.times do |i|
      mixed_string[i*2] = base[i]
      mixed_string[i*2 + 1] = salt[i]
    end

    mixed_string
  end
end
