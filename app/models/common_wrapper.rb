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

  def find_user(external_id)
    response = request(
      "#{services_endpoint[:community_service]}/users",
      params: {
        "external_id::integer" => "eq.#{external_id}"
      },
      action: :get,
      headers: { 'Accept' => 'application/vnd.pgrst.object+json' },
    ).run

    if response.success?
      json = ActiveSupport::JSON.decode(response.body)
      common_id = json.try(:[], 'id')
      return common_id
    end

    return
  end
  def index_user(resource)
    response = Typhoeus::Request.new(
      "#{services_endpoint[:community_service]}/rpc/user",
      body: {
        data: resource.common_index.to_json
      }.to_json,
      headers: base_headers(resource.current_sign_in_ip),
      method: :post
    ).run

    if response.code == 200
      json = ActiveSupport::JSON.decode(response.body)
      common_id = json.try(:[], 'id') || json.try(:[], 0).try(:[], 'user').try(:[], 'id')
      resource.update_column(:common_id, common_id)
      return common_id;
    else
      puts response.body
    end
  end

  def index_project(resource)
    response = Typhoeus::Request.new(
      "#{services_endpoint[:project_service]}/rpc/project",
      body: {
        data: resource.common_index.to_json
      }.to_json,
      headers: base_headers(resource.user.current_sign_in_ip),
      method: :post
    ).run

    if response.code == 200
      json = ActiveSupport::JSON.decode(response.body)
      common_id = json.try(:[], 'id') || json.try(:[], 0).try(:[], 'project').try(:[], 'id')
      resource.update_column(:common_id, common_id)
      return common_id;
    else
      puts response.body
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

  def request(endpoint, options = {})
    Typhoeus::Request.new(
      endpoint,
      params: options[:params] || {},
      body: options[:body] || {},
      headers: base_headers(options[:current_ip]).merge(options[:headers] || {}),
      method: options[:action] || :get
    )
  end

end
