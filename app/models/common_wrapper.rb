# frozen_string_literal: true
class CommonWrapper
  attr_accessor :api_key

  def initialize(api_key)
    @api_key = api_key
  end

  def services_endpoint
    @services_endpoint ||= {
      community_service: CatarseSettings[:common_community_service_api],
      project_service: CatarseSettings[:common_project_service_api],
      payment_service: CatarseSettings[:common_payment_service_api]
    }
  end

  def index_user(user)
    response = Typhoeus::Request.new(
      "#{services_endpoint[:community_service]}/rpc/user",
      body: {
        data: user.common_index.to_json
      }.to_json,
      headers: base_headers(user.current_sign_in_ip),
      method: :post
    ).run
    if response.code == 200
      json = ActiveSupport::JSON.decode(response.body)
      common_id = json.try(:[], 0).try(:[], 'user').try(:[], 'id')
      user.update_column(:common_id, common_id)
      return common_id;
    end
  end

  def base_headers(current_ip)
    h = {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }.merge!({ 'Authorization' => "Bearer #{@api_key}" })

    if Rails.env.development?
      h.merge!({ 'X-Forwarded-For' => current_ip })
    end

    h
  end

end
