# Kamigami 使用者權限票証類別
class Briareus::Torii::Ticket
  def initialize(uuid, ticket_id, token = nil, chain = nil)
    @uuid = uuid
    @ticket_id = ticket_id

    if token
      @chain = token.split(',')
    elsif chain
      @chain = chain.dup
    end
  end

  def uuid
    @uuid
  end

  def ticket_id
    @ticket_id
  end

  def get_hash
    @chain[-1]
  end

  def chain
    @chain.dup
  end

  def token
    @chain.join(',')
  end

  def permission_flag
    if(@permission_flag == nil)
      @permission_flag = 0xffff
      @chain[0..-2].each do |sign|
        @permission_flag &= sign.split(";", 2).first.to_i(16)
      end
    end
    @permission_flag
  end

  def sign_subtoken(issuer, permission_flag = 0xffff)
    salt = "#{permission_flag.to_s(16)};#{Time.now.utc.strftime("%s")};#{issuer}"

    chain = @chain.dup
    mixed_token = Briareus::Torii.mixing_salt(chain[-1], salt)
    hashed_token = Digest::SHA256.new.update(mixed_token).hexdigest

    chain.insert(-2, salt)
    chain[-1] = hashed_token
    Briareus::Torii::Ticket.new(@uuid, @ticket_id, nil, chain)
  end

  def validate_permission(request_flag)
    ((permission_flag & request_flag) == request_flag)
  end

  def to_query
    {u: @uuid, tid: @ticket_id, t: token}
  end

  def to_json
    {user: @uuid, ticket_id: @ticket_id, token: token}
  end
end
