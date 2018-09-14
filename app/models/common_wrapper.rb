# frozen_string_literal: true
class CommonWrapper
  attr_accessor :api_key

  def initialize(api_key)
    @api_key = api_key
  end

  def common_api_endpoint
    @common_api_endpoint ||= URI::parse(CatarseSettings[:common_api])
  end

  def services_endpoint
    @services_endpoint ||= {
      proxy_service: URI::parse(CatarseSettings[:common_proxy_service_api]),
      community_service: URI::parse(CatarseSettings[:common_community_service_api]),
      project_service: URI::parse(CatarseSettings[:common_project_service_api]),
      analytics_service: URI::parse(CatarseSettings[:common_analytics_service_api]),
      recommender_service: URI::parse(CatarseSettings[:common_recommender_service_api]),
      payment_service: URI::parse(CatarseSettings[:common_payment_service_api])
    }
  end

  def list_subscriptions(opts = {})
    opts[:limit] = 10 unless opts[:limit].present? || opts[:limit].to_i > 30
    opts[:offset] = 0 unless opts[:offset].present?

    uri = services_endpoint[:payment_service]
    uri.path = '/subscriptions'
    response = request(
      uri.to_s,
      { params: opts }
    ).run

    if response.success?
      json = ActiveSupport::JSON.decode(response.body)
      return json
    else
      Rails.logger.info(response.body)
    end

    return
  end

  def list_payments(opts = {})
    opts[:limit] = 10 unless opts[:limit].present? || opts[:limit].to_i > 30
    opts[:offset] = 10 unless opts[:offset].present?

    uri = services_endpoint[:payment_service]
    uri.path = '/payments'
    response = request(
      uri.to_s,
      { params: opts }
    ).run

    if response.success?
      json = ActiveSupport::JSON.decode(response.body)
      return json
    else
      Rails.logger.info(response.body)
    end

    return
  end

  def temp_login_api_key(resource)
    uri = services_endpoint[:proxy_service]
    uri.path = '/v1/users/login'
    response = request(
      uri.to_s,
      body: {
        user: {
          id: resource.common_id
        }
      }.to_json,
      action: :post,
    ).run

    if response.success?
      json = ActiveSupport::JSON.decode(response.body)
      token = json.try(:[], 'api_key')
      return token
    else
      Rails.logger.info(response.body)
    end

    return
  end

  def user_api_key(resource)
    uri = services_endpoint[:community_service]
    uri.path = '/rpc/create_scoped_user_session'
    response = request(
      uri.to_s,
      body: {
        id: resource.common_id
      }.to_json,
      action: :post,
      current_ip: resource.current_sign_in_ip
    ).run

    if response.success?
      json = ActiveSupport::JSON.decode(response.body)
      token = json.try(:[], 'token')
      return token
    else
      Rails.logger.info(response.body)
    end

    return
  end

  def find_project(external_id)
    uri = services_endpoint[:project_service]
    uri.path = '/projects'
    response = request(
      uri.to_s,
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
    else
      Rails.logger.info(response.body)
    end

    return
  end

  def find_user(external_id)
    uri = services_endpoint[:community_service]
    uri.path = '/users'
    response = request(
      uri.to_s,
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
    else
      Rails.logger.info(response.body)
    end

    return
  end

  def find_post(external_id)
    uri = services_endpoint[:proxy_service]
    uri.path = '/posts'
    response = request(
      uri.to_s,
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
    else
      Rails.logger.info(response.body)
    end

    return
  end

  def find_goal(external_id)
    uri = services_endpoint[:project_service]
    uri.path = '/goals'
    response = request(
      uri.to_s,
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
    else
      Rails.logger.info(response.body)
    end

    return
  end

  def find_direct_message(external_id)
    uri = services_endpoint[:proxy_service]
    uri.path = '/direct_messages'
    response = request(
      uri.to_s,
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
    else
      Rails.logger.info(response.body)
    end

    return
  end

  def find_reward(external_id)
    uri = services_endpoint[:project_service]
    uri.path = '/rewards'
    response = request(
      uri.to_s,
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
    else
      Rails.logger.info(response.body)
    end

    return
  end

  def train_recommender(resource)
    uri = services_endpoint[:recommender_service]
    uri.path = '/traincf'
    response = request(
      uri.to_s,
      action: :get,
      current_ip: resource.current_sign_in_ip
    ).run

    if response.success?
      return ActiveSupport::JSON.decode(response.body)
    else
      Rails.logger.info(response.body)
    end

    return
  end

  def index_user(resource)
    uri = services_endpoint[:community_service]
    uri.path = '/rpc/user'
    response = request(
      uri.to_s,
      body: {
        data: resource.common_index.to_json
      }.to_json,
      action: :post,
      current_ip: resource.current_sign_in_ip
    ).run

    if response.success?
      json = ActiveSupport::JSON.decode(response.body)
      common_id = json.try(:[], 'id')
    else
      Rails.logger.info(response.body)
      common_id = find_user(resource.id)
    end

    resource.update_column(:common_id,
                           common_id.presence || resource.common_id)
    return common_id;
  end

  def index_project(resource)
    unless resource.user.common_id.present?
      resource.user.index_on_common
      resource.user.reload
    end

    uri = services_endpoint[:project_service]
    uri.path = '/rpc/project'
    response = request(
      uri.to_s,
      body: {
        data: resource.common_index.to_json
      }.to_json,
      action: :post,
      current_ip: resource.user.current_sign_in_ip
    ).run

    if response.success?
      json = ActiveSupport::JSON.decode(response.body)
      common_id = json.try(:[], 'id')
    else
      Rails.logger.info(response.body)
      common_id = find_project(resource.id)
    end

    resource.update_column(
      :common_id,
      (common_id.presence || resource.common_id)
    )

    return common_id;
  end

  def index_direct_message(resource)
    if resource.project && !resource.project.common_id.present?
      resource.project.index_on_common
      resource.project.reload
    end

    if resource.user && !resource.user.common_id.present?
      resource.user.index_on_common
    end

    if resource.to_user && !resource.to_user.common_id.present?
      resource.to_user.index_on_common
    end

    uri = services_endpoint[:proxy_service]

    uri.path = '/v1/direct_messages'

    response = request(
      uri.to_s,
      body: {
        direct_message:
        resource.common_index
      }.to_json,
      action: :post,
      current_ip: resource.project.user.current_sign_in_ip,
      headers: {'Content-Type' => 'application/json'},
    ).run

    if response.success?
      json = ActiveSupport::JSON.decode(response.body)
      common_id = json.try(:[], 'id')
    else
      Rails.logger.info(response.body)
      common_id = find_direct_message(resource.id)
    end

    resource.update_column(
      :common_id,
      (common_id.presence || resource.common_id)
    )

    return common_id;
  end

  def index_project_post(resource)
    unless resource.project.common_id.present?
      resource.project.index_on_common
      resource.project.reload
    end

    uri = services_endpoint[:proxy_service]

    return if resource.project.common_id.nil?
    uri.path = if resource.common_id.present?
                 '/v1/projects/' + resource.project.common_id + '/posts/' + resource.common_id
               else
                 '/v1/projects/' + resource.project.common_id + '/posts'
               end
    response = request(
      uri.to_s,
      body: {
        post:
        resource.common_index
      }.to_json,
      action: resource.common_id.present? ? :patch : :post,
      current_ip: resource.project.user.current_sign_in_ip,
      headers: {'Content-Type' => 'application/json'},
    ).run

    if response.success?
      json = ActiveSupport::JSON.decode(response.body)
      common_id = json.try(:[], 'id')
    else
      Rails.logger.info(response.body)
      common_id = find_post(resource.id)
    end

    resource.update_column(
      :common_id,
      (common_id.presence || resource.common_id)
    )

    return common_id;
  end

  def index_goal(resource)
    unless resource.project.common_id.present?
      resource.project.index_on_common
      resource.project.reload
    end

    uri = common_api_endpoint

    return if resource.project.common_id.nil?
    uri.path = if resource.common_id.present?
                 '/v1/projects/' + resource.project.common_id + '/goals/' + resource.common_id
               else
                 '/v1/projects/' + resource.project.common_id + '/goals'
               end
    response = request(
      uri.to_s,
      body: {
        goal:
        resource.common_index
      }.to_json,
      action: resource.common_id.present? ? :patch : :post,
      current_ip: resource.project.user.current_sign_in_ip,
      headers: {'Content-Type' => 'application/json'},
    ).run

    if response.success?
      json = ActiveSupport::JSON.decode(response.body)
      common_id = json.try(:[], 'id')
    else
      Rails.logger.info(response.body)
      common_id = find_goal(resource.id)
    end

    resource.update_column(
      :common_id,
      (common_id.presence || resource.common_id)
    )

    return common_id;
  end

  def index_reward(resource)
    unless resource.project.common_id.present?
      resource.project.index_on_common
      resource.project.reload
    end

    uri = services_endpoint[:project_service]
    uri.path = '/rpc/reward'
    response = request(
      uri.to_s,
      body: {
        data: resource.common_index.to_json
      }.to_json,
      action: :post,
      current_ip: resource.project.user.current_sign_in_ip
    ).run

    if response.success?
      json = ActiveSupport::JSON.decode(response.body)
      common_id = json.try(:[], 'id')
    else
      Rails.logger.info(response.body)
      common_id = find_reward(resource.id)
    end

    resource.update_column(
      :common_id,
      (common_id.presence || resource.common_id)
    )

    return common_id;
  end

  def finish_project(resource)
    unless resource.common_id.present?
      resource.index_on_common
      resource.reload
    end

    uri = services_endpoint[:project_service]
    uri.path = '/rpc/finish_project'
    response = request(
      uri.to_s,
      body: {
        id: resource.common_id
      }.to_json,
      action: :post,
      current_ip: resource.user.current_sign_in_ip
    ).run

    if response.success?
      json = ActiveSupport::JSON.decode(response.body)
      common_id = json.try(:[], 'id')
    else
      Rails.logger.info(response.body)
      common_id = find_project(resource.id)
    end

    return common_id;
  end

  def chargeback_payment(payment_uuid)
    uri = services_endpoint[:payment_service]
    uri.path = '/rpc/chargeback_payment'
    response = request(
      uri.to_s,
      body: {
        id: payment_uuid
      }.to_json,
      action: :post
    ).run

    Rails.logger.info(response.body)
    response.success?
  end

  def cancel_subscription(resource)
    uri = services_endpoint[:payment_service]
    uri.path = '/rpc/cancel_subscription'
    response = request(
      uri.to_s,
      body: {
        id: resource.id
      }.to_json,
      action: :post,
      current_ip: resource.user.current_sign_in_ip
    ).run

    if response.success?
      json = ActiveSupport::JSON.decode(response.body)
      return json.try(:[], 'id')
    else
      Rails.logger.info(response.body)
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
