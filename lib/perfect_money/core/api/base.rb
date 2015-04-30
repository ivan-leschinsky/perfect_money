class PerfectMoney::Core::API::Base
  SERVICE_ENDPOINT = 'https://perfectmoney.is'
  include PerfectMoney::Core::Util::HTTP

  attr_writer :service_name

  attr_accessor :account

  class << self
    def user_agent
      @user_agent ||= "PerfectMoneySDK/Core #{PerfectMoney::VERSION}"
    end
  end

  def initialize(account_name)
    self.account = account_collection[account_name]
  end

  def service_name
    raise 'Need to be overridden'
  end

  def uri
    @uri ||=
    begin
      uri      = URI.parse("#{SERVICE_ENDPOINT}/#{service_name}")
      uri.path = uri.path.gsub(/\/+/, "/")
      uri
    end
  end

  def http
    @http ||= create_http_connection(uri)
  end

  def default_http_header
    { "User-Agent" => self.class.user_agent }
  end

  def api_call(payload)
    payload[:header] = default_http_header.merge(payload[:header])
    payload[:uri]    ||= uri.dup
    payload[:http]   ||= http.dup
    payload[:body]   = encode_www_form(payload[:params])

    response = http_call(payload)
    response.body
  end

  private

  def post_request(params, header = {})
    api_call(method: :post, params: params, header: header)
  end
end
