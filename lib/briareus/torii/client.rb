# 帳號管理系統存取物件
class Briareus::Torii::Client < Briareus::CommunicationBase
  def on_connected
    if not validate_peer_cn("torii.server.#{@kamigami_prefix}")
      raise SecurityError.new("Torii server's cert is not legitimate")
    end

    response = make_request(0x0, nil)
    @server_name = response['n']
    @server_version = response['v']
  end

  # Input
  #   Case1: :ticket => ticket object
  #   Case2: :user => "uuid string", :ticket_id => 123, :token => "hashed token"
  def get_user_profile(options = {})
    query = create_ticket_query(options)
    make_request(Briareus::Torii::GET_ACCOUNT_PROFILE, query)
  end

  # Output:
  #   Case1: {'@': true, 'username': 'username@fafa.soso'}
  #   Case2: {'@': false, 'err': 'BAD_REQUEST', 'errno': 255}
  def query_username(uuid)
    make_request(Briareus::Torii::QUERY_USERNAME, uuid: uuid)
  end

  # Input is same as get_user_profile
  def validate_ticket(options = {})
    query = create_ticket_query(options)
    make_request(Briareus::Torii::VALIDATE_TICKET, query)
  end

  protected

  def create_ticket_query(options = {})
    options[:ticket] ?
      options[:ticket].to_query :
      {u: options[:user], tid: options[:ticket_id], t: options[:token]}
  end
end
