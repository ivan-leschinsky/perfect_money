class PerfectMoney::Core::API::History < PerfectMoney::Core::API::Base
  def service_name
    @service_name ||= "acct/historycsv.asp"
  end

  def get_history(start_date, end_date)
    data = post_request(params(start_date, end_date))
    ::CSV.new(data, headers: %w(time type batch currency amount fee payer_acct payee_acct payment_id memo))
  end

  private

  def params(start_date, end_date)
    start_date = {
      startmonth: start_date[0],
      startday:   start_date[1],
      startyear:  start_date[2]
    }
    end_date   = {
      endmonth: end_date[0],
      endday:   end_date[1],
      endyear:  end_date[2]
    }
    account.auth_hash.merge(start_date).merge(end_date)
  end
end
