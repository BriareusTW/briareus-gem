class Briareus::Miko::Client
  include HTTParty
  base_uri Briareus::Miko.base_uri

  def self.get_ticket_from_ax_response(ax)
    ax_response_key = ax[Briareus::Miko.openid_ticket_url].first
    token_request_key = "#{Briareus::Miko.phrases}$#{ax_response_key}"
    hash = Digest::SHA1.hexdigest(token_request_key)
    get(Briareus::Miko.ticket_path % hash)
  end

  def self.valid_ticket?(ticket)
    Briareus::Torii::Client.open(Briareus::Miko.host,
                                 Briareus::Miko.port,
                                 Briareus::Miko.pkey,
                                 Briareus::Miko.cert,
                                 Briareus::Miko.ca,
                                 Briareus::Miko.kamigami_prefix) do |torii|
      ticket = ticket.to_torii_ticket
      torii.validate_ticket(ticket: ticket)['@']
    end
  end

  def self.get_profile(ticket)
    Briareus::Torii::Client.open(Briareus::Miko.host,
                                 Briareus::Miko.port,
                                 Briareus::Miko.pkey,
                                 Briareus::Miko.cert,
                                 Briareus::Miko.ca,
                                 Briareus::Miko.kamigami_prefix) do |torii|
      ticket = ticket.to_torii_ticket
      torii.get_user_profile(ticket: ticket)['profile']
    end
  end

  def self.post_payment_app(user, game)
    form = {
      user: user.user_id,
      hash: generate_hash,
      region: 'TW',      # TODO: load from user data
      currency: 'TWD',   # TODO: load from user data
      price: game.price, # TODO: load from game data
      title: game.title,
      subtitle: game.subtitle,
      app: game.application.id
    }
    form_json = ActiveSupport::JSON.encode(form)
    signature = OpenSSL::HMAC.hexdigest('sha1', Briareus::Miko.phrases, form_json)
    results = post(Briareus::Miko.payment_app_path, body: {
      form: form_json,
      signature: signature,
      phrases_id: Briareus::Miko.phrases_id
    })
    if results.success?
      results
    else
      raise ServerError
    end
  end

  HASH_CHARACTERS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.chars.freeze

  def self.generate_hash
    (1..8).map { HASH_CHARACTERS.sample }.join
  end

  class Error < StandardError
  end

  class ServerError < Error
    def message
      'Server error'
    end

    def as_json(options = nil)
      {error: message}
    end
  end
end
