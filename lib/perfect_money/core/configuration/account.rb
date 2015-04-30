class PerfectMoney::Core::Configuration::Account
  attr_accessor :id, :account_id, :pass_phrase, :secret_key, :deposit_account, :withdrawal_account,
                :deposit_account_balance, :withdrawal_account_balance

  def initialize(options)
    merge!(options)

    self.deposit_account_balance    = {}
    self.withdrawal_account_balance = {}
  end

  def merge!(options)
    options.each do |key, value|
      send("#{key}=", value)
    end
    self
  end

  def sync_balance
    PerfectMoney::Core::API::Balance.new(self.id).sync_with_account
  end

  def auth_hash
    {
      AccountID:  account_id,
      PassPhrase: pass_phrase
    }
  end
end
