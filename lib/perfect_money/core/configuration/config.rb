class PerfectMoney::Core::Configuration::Config
  attr_accessor :http_timeout, :http_proxy

  def initialize(options)
    merge!(options)
  end

  def merge!(options)
    options.each do |key, value|
      send("#{key}=", value)
    end
    self
  end
end
