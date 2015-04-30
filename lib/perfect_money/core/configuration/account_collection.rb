class PerfectMoney::Core::Configuration::AccountCollection
  extend Forwardable

  attr_reader :accounts

  def_delegator :accounts, :[]

  def initialize(options)
    if options.is_a?(Array)
      @accounts = {}
      options.each do |account_options|
        account              = Account.new(account_options)
        accounts[account.id] = account
      end
    else
      fail "invalid argument 'options'"
    end
  end
end
