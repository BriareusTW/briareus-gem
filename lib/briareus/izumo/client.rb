# 遊戲管理系統存取物件
class Briareus::Izumo::Client < Briareus::CommunicationBase
  def dispatch(options = {})
    message = options.slice(:aid, :user, :ticket_id, :token, :ip)
    response = make_request(EXCHANGE_TOKEN, message)
    unless response['@'] == true && response.has_key?('sukumizu')
      raise 'server_error'
    end
    return response['sukumizu']
  end
end
