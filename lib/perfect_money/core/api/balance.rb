class PerfectMoney::Core::API::Balance < PerfectMoney::Core::API::Base
  attr_accessor :result

  def service_name
    @service_name ||= 'acct/balance.asp'
  end

  def get_balance
    sync_with_account
    result
  end

  def sync_with_account
    result   = {}
    response_body = post_request(params)
    html_dom      = Nokogiri::HTML(response_body)
    html_dom.xpath('/html/body/table/tr')[1..-1].each do |tr|
      tds = tr.xpath('td')
      sync_account_balance(tds[0].content, tds[1].content)
      result[tds[0].content] = tds[1].content.to_f
    end
    true
  end

  private

  def sync_account_balance(account_number, amount)

    syncronizer = Proc.new do |type_of_account|
      account.send("#{type_of_account}_account").each_pair do |currency, acct_number|
        if account_number == acct_number
          account.send("#{type_of_account}_account_balance")[currency] = amount.to_f
        end
      end
    end

    syncronizer.call('deposit')
    syncronizer.call('withdrawal')
  end

  private

  def params
    account.auth_hash
  end
end
