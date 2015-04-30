require 'net/https'
require 'uri'

class PerfectMoney::Core::Util::HTTP
  include PerfectMoney::Core::Configuration

  def create_http_connection(uri)
    new_http(uri).tap do |http|
      if config.http_timeout
        http.open_timeout = config.http_timeout
        http.read_timeout = config.http_timeout
      end
      configure_ssl(http) if uri.scheme == "https"
    end
  end

  def new_http(uri)
    if config.http_proxy
      proxy = URI.parse(config.http_proxy)
      Net::HTTP.new(uri.host, uri.port, proxy.host, proxy.port, proxy.user, proxy.password)
    else
      Net::HTTP.new(uri.host, uri.port)
    end
  end

  def configure_ssl(http)
    http.tap do |https|
      https.use_ssl = true
    end
  end

  def url_join(path, action)
    path.sub(/\/?$/, "/#{action}")
  end

  def http_call(payload)
    http = payload[:http] || create_http_connection(payload[:uri])
    http.start do |session|
      if [:get, :delete, :head].include? payload[:method]
        session.send(payload[:method], payload[:uri].request_uri, payload[:header])
      else
        session.send(payload[:method], payload[:uri].request_uri, payload[:body], payload[:header])
      end
    end
  end

  # Generate header based on given header keys and properties
  # === Arguments
  # * <tt>header_keys</tt> -- List of Header keys for the properties
  # * <tt>properties</tt>  -- properties
  # === Return
  #  Hash with header as key property as value
  # === Example
  # map_header_value( { :username => "X-PAYPAL-USERNAME"}, { :username => "guest" })
  # # Return: { "X-PAYPAL-USERNAME" => "guest" }
  def map_header_value(header_keys, properties)
    header = {}
    properties.each do |key, value|
      key         = header_keys[key]
      header[key] = value.to_s if key and value
    end
    header
  end

  def encode_www_form(hash)
    if defined? URI.encode_www_form
      URI.encode_www_form(hash)
    else
      hash.map { |key, value| "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}" }.join("&")
    end
  end
end
