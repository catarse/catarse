class ApiWrapper
  TOKEN_TTL = 1.hour
  attr_accessor :current_user

  def initialize(current_user)
    @current_user = current_user
  end

  def jwt
    @jwt ||= JsonWebToken.sign(claims, key: CatarseSettings[:jwt_secret])
  end

  def request(endpoint, options = {})
    Typhoeus::Request.new(
      "#{CatarseSettings[:api_host]}/#{endpoint}",
      params: options[:params] || {},
      body: options[:body] || {},
      headers: base_headers.merge(options[:headers] || {}),
      method: options[:action] || :get
    )
  end

  def base_headers
    {
      "Authorization" => "Bearer #{jwt}",
      "Accept" => 'application/json',
      "Content-Type" => 'application/json'
    }
  end

  private

  def claims
    {
      role: @current_user.admin ? 'admin' : 'web_user',
      user_id: @current_user.id.to_s,
      exp: (Time.now + TOKEN_TTL).to_i
    }
  end
end
