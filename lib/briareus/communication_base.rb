# 通訊用基礎類別
class Briareus::CommunicationBase
  def self.open(*args)
    client = new(*args)
    result = yield(client)
    client.close
    result
  end

  def initialize(host, port, private_key_file_path, cert_file_path, ca_file_path, kamigami_prefix = 'kamigami')
    @kamigami_prefix = kamigami_prefix
    tcp_socket = TCPSocket.open(host, port)
    ssl_context = OpenSSL::SSL::SSLContext.new

    ssl_context.cert = OpenSSL::X509::Certificate.new(File.open(cert_file_path.to_s))
    ssl_context.key = OpenSSL::PKey::RSA.new(File.open(private_key_file_path.to_s))
    ssl_context.ca_file = ca_file_path.to_s

    ssl_context.verify_mode = OpenSSL::SSL::VERIFY_PEER
    ssl_context.ssl_version = :TLSv1
    @ssl_socket = OpenSSL::SSL::SSLSocket.new(tcp_socket, ssl_context)
    @ssl_socket.sync_close = true
    @ssl_socket.connect

    @unpacker = MessagePack::Unpacker.new
    on_connected
  end

  def on_connected
  end

  def close
    @ssl_socket.close
    @ssl_socket = nil
  end

  def validate_peer_cn(common_name)
    x509 = @ssl_socket.peer_cert
    subjects = x509.subject.to_a
    subjects.each do |entry|
      return true if entry[0] == 'CN' && entry[1] == common_name
    end
    return false
  end

  def make_request(verb, message)
    buffer = MessagePack.pack([verb, message])
    @ssl_socket.syswrite(buffer)

    loop do
      @unpacker.feed(@ssl_socket.sysread(4096))
      for response in @unpacker
        return response
      end
    end
  end
end
