class PerfectMoney::Core::API::Withdrawal < PerfectMoney::Core::API::Base
  CURRENCIES = ["usd", "eur", "gold"]

  attr_accessor :currency_type

  def initialize(account_id, currency_type)
    fail 'invalid currency' unless CURRENCIES.include?(currency_type.to_s)

    self.currency_type = currency_type.to_s
    super(account_id)
  end

  def service_name
    @service_name ||= "acct/confirm.asp"
  end

  def do_withdrawal(payee_acct, amount, payment_id, memo)
    result   = {}
    html_dom = post_request(params(payee_acct, amount, payment_id, memo))
    scanned  = html_dom.scan(/Error: ([\w\s]*)\n/)
    if scanned.empty?
      Nokogiri::HTML(html_dom).xpath("/html/body/table/tr")[1..-1].each do |tr|
        tds = tr.xpath("td")

        result[tds[0].content.downcase] = tds[1].content
      end
    else
      result[:error] = scanned[0][0]
    end
    result
  end

  private

  def params(payee_acct, amount, payment_id, memo)
    withdrawal_hash = {
      "Payer_Account" => account.withdrawal_account[currency_type],
      "Payee_Account" => payee_acct,
      "Amount"        => amount,
      "Memo"          => memo,
      "PAYMENT_ID"    => payment_id,
    }
    account.auth_hash.merge(withdrawal_hash)
  end
end
