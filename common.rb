module RailsCastsCommon
  attr_reader :subscription_code, :cookie_string,
  def get_subscription_code
    begin
      require_relative 'subscription_code' #code = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    rescue
      puts "Please add your subscription code from subscription_code.rb.example"
      exit(0)
    end
    @subscription_code  = SubscriptionCode::CODE
    @cookie_string      = "token="+@subscription_code
  end

  # Used from https://github.com/defunkt/gist/blob/master/lib/gist.rb
  def proxy
    @proxy ||=
    if ENV['https_proxy'] && !ENV['https_proxy'].empty?
      URI(ENV['https_proxy'])
    elsif ENV['http_proxy'] && !ENV['http_proxy'].empty?
      URI(ENV['http_proxy'])
    else
      nil
    end
  end

end