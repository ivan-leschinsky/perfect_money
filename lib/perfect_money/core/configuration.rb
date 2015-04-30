class PerfectMoney::Core::Configuration
  autoload :AccountCollection, 'perfect_money/core/configuration/account_collection'
  autoload :Account, 'perfect_money/core/configuration/account'
  autoload :Config, 'perfect_money/core/configuration/config'

  def account_collection
    @account_collection ||= PerfectMoney::Core::Configuration.build_account_collection
  end

  def config
    @config ||= PerfectMoney::Core::Configuration.build_config
  end

  class << self
    def load(config_file_path, default_env = default_environment)
      @@config_cache        = {}
      @@configurations      = read_configurations_from_file(config_file_path)
      @@default_environment = default_env
      true
    end

    def build_account_collection(env = default_environment)
      if configurations[env]
        @@config_cache["#{env}_accounts"] ||= AccountCollection.new(configurations[env]["accounts"])
      else
        raise "Configuration '#{env}' not found"
      end
    end

    def build_config(env = default_environment)
      if configurations[env]
        @@config_cache["#{env}_config"] ||= Config.new(configurations[env]["config"])
      else
        raise "Configuration '#{env}' not found"
      end
    end

    def configurations
      @@configurations ||= read_configurations_from_file
    end

    def default_environment
      @@default_environment ||= "development"
    end

    def default_environment=(val)
      @@default_environment = val.to_s
    end

    def read_configurations_from_file(config_file_path = 'config/perfect_money.yml')
      YAML.load_file(config_file_path)
    end
  end
end
