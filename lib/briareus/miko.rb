module Briareus::Miko
  autoload :Client, 'briareus/miko/client'

  class << self
    attr_accessor :host, :port, :pkey, :cert, :ca, :kamigami_prefix, :base_uri,
                  :openid_ticket_url, :phrases, :ticket_path, :phrases_id,
                  :payment_app_path

    def config(&block)
      block.call(self)
    end
  end
end
