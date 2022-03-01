# frozen_string_literal: true

class CommonWrapper
  attr_accessor :api_key

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

  def subscriptions_montly_report_for(project_id, ext = 'csv')
    ext = 'csv' unless %w[csv xls].include?(ext)
    @api_key = proxy_api_key
    uri = services_endpoint[:proxy_service]
    uri.path = "/v1/projects/#{project_id}/subscriptions_monthly_report_for_project_owners.#{ext}"
    request(uri.to_s, {}).run
  end

  def subscriptions_report_for(project_id, ext = 'csv')
    ext = 'csv' unless %w[csv xls].include?(ext)
    @api_key = proxy_api_key
    uri = services_endpoint[:proxy_service]
    uri.path = "/v1/projects/#{project_id}/subscriptions_report_for_project_owners.#{ext}"
    request(uri.to_s, {}).run
  end


  def list_subscriptions(opts = {})
    @api_key = common_api_key
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
    @api_key = common_api_key
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
    @api_key = proxy_api_key
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
    @api_key = common_api_key
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
    @api_key = common_api_key
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
    @api_key = common_api_key
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
    @api_key = proxy_api_key
    uri = services_endpoint[:proxy_service]
    resource = ProjectPost.find external_id
    uri.path = '/v1/projects/' + resource.project.common_id + '/posts'
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

  def find_address(external_id)
    @api_key = proxy_api_key
    uri = services_endpoint[:proxy_service]
    resource = Address.find external_id
    uri.path = '/v1/addresses'
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

  def find_contribution(external_id)
    @api_key = proxy_api_key
    uri = services_endpoint[:proxy_service]
    resource = Contribution.find external_id
    uri.path = '/v1/projects/' + resource.project.common_id + '/contributions'
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
    @api_key = proxy_api_key
    uri = services_endpoint[:proxy_service]
    resource = Goal.find external_id
    uri.path = '/v1/projects/' + resource.project.common_id + '/goals'
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
    @api_key = proxy_api_key
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
    @api_key = common_api_key
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
    @api_key = common_api_key
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
    return unless resource.id.present?
    @api_key = common_api_key
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

    resource.update_column(
      :common_id, common_id
    ) if common_id.present?
    common_id
  end

  def index_project(resource)
    return unless resource.id.present?
    unless resource.user.common_id.present?
      resource.user.index_on_common
      resource.user.reload
    end

    @api_key = common_api_key
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
      :common_id, common_id
    ) if common_id.present?

    common_id
  end

  def index_direct_message(resource)
    return unless resource.id.present?
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

    @api_key = proxy_api_key
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
      common_id = json.try(:[], 'direct_message_id')
    else
      Rails.logger.info(response.body)
      common_id = find_direct_message(resource.id)
    end

    resource.update_column(
      :common_id, common_id
    ) if common_id.present?

    common_id
  end

  def index_country(resource)
    return unless resource.id.present?

    @api_key = proxy_api_key
    uri = services_endpoint[:proxy_service]

    uri.path = '/v1/countries'
    response = request(
      uri.to_s,
      body: {
        country:
          resource.common_index
      }.to_json,
      action: :post,
      headers: {'Content-Type' => 'application/json'},
    ).run

    if response.success?
      json = ActiveSupport::JSON.decode(response.body)
      common_id = json.try(:[], 'country_id')
    end

    resource.update_column(
      :common_id, common_id
    ) if common_id.present?

    common_id
  end

  def index_state(resource)
    return unless resource.id.present?

    @api_key = proxy_api_key
    uri = services_endpoint[:proxy_service]

    uri.path = '/v1/states'
    response = request(
      uri.to_s,
      body: {
        state:
        resource.common_index
      }.to_json,
      action: :post,
      headers: {'Content-Type' => 'application/json'},
    ).run

    if response.success?
      json = ActiveSupport::JSON.decode(response.body)
      common_id = json.try(:[], 'state_id')
    end

    resource.update_column(
      :common_id, common_id
    ) if common_id.present?

    common_id
  end

  def index_address(resource)
    return unless resource.id.present?

    if resource.state && !resource.state.common_id.present?
      resource.country.index_on_common
    end

    if resource.country && !resource.country.common_id.present?
      resource.country.index_on_common
    end

    @api_key = proxy_api_key
    uri = services_endpoint[:proxy_service]

    uri.path = if resource.common_id.present?
                 '/v1/addresses/' + resource.common_id
               else
                 '/v1/addresses'
               end
    response = request(
      uri.to_s,
      body: {
        address:
        resource.common_index
      }.to_json,
      action: resource.common_id.present? ? :patch : :post,
      headers: {'Content-Type' => 'application/json'},
    ).run

    if response.success?
      json = ActiveSupport::JSON.decode(response.body)
      common_id = json.try(:[], 'address_id')
    else
      Rails.logger.info(response.body)
      common_id = find_address(resource.id)
    end

    resource.update_column(
      :common_id, common_id
    ) if common_id.present?

    common_id
  end

  def index_contribution(resource)
    return unless resource.id.present?
    unless resource.project.common_id.present?
      resource.project.index_on_common
      resource.project.reload
    end

    unless resource.user.common_id.present?
      resource.user.index_on_common
      resource.user.reload
    end

    if resource.reward && !resource.reward.common_id.present?
      resource.reward.index_on_common
      resource.reward.reload
    end

    return unless resource.project.present?
    return unless resource.project.common_id.present?

    @api_key = proxy_api_key
    uri = services_endpoint[:proxy_service]

    return if resource.project.common_id.nil?
    uri.path = if resource.common_id.present?
                 '/v1/projects/' + resource.project.common_id + '/contributions/' + resource.common_id
               else
                 '/v1/projects/' + resource.project.common_id + '/contributions'
               end
    response = request(
      uri.to_s,
      body: {
        contribution:
        resource.common_index
      }.to_json,
      action: resource.common_id.present? ? :patch : :post,
      current_ip: resource.project.user.current_sign_in_ip,
      headers: {'Content-Type' => 'application/json'},
    ).run

    if response.success?
      json = ActiveSupport::JSON.decode(response.body)
      common_id = json.try(:[], 'contribution_id')
    else
      Rails.logger.info(response.body)
      common_id = find_contribution(resource.id)
    end

    resource.update_column(
      :common_id, common_id
    ) if common_id.present?

    common_id
  end

  def index_project_post(resource)
    return unless resource.id.present?
    unless resource.project.common_id.present?
      resource.project.index_on_common
      resource.project.reload
    end

    return unless resource.project.present?
    return unless resource.project.common_id.present?

    @api_key = proxy_api_key
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
      common_id = json.try(:[], 'post_id')
    else
      Rails.logger.info(response.body)
      common_id = find_post(resource.id)
    end

    resource.update_column(
      :common_id, common_id
    ) if common_id.present?

    common_id
  end

  def index_goal(resource)
    return unless resource.id.present?
    unless resource.project.common_id.present?
      resource.project.index_on_common
      resource.project.reload
    end

    return unless resource.project.present?
    return unless resource.project.common_id.present?

    @api_key = proxy_api_key
    uri = services_endpoint[:proxy_service]

    return if resource.project.common_id.nil?
    uri.path = if resource.common_id.present?
                 '/v1/projects/' + resource.project.common_id + '/goals/' + resource.common_id
               else
                 '/v1/projects/' + resource.project.common_id + '/goals'
               end
    response = request(
      uri.to_s,
      body: {
        goal: resource.common_index
      }.to_json,
      action: resource.common_id.present? ? :patch : :post,
      current_ip: resource.project.user.current_sign_in_ip,
      headers: {'Content-Type' => 'application/json'},
    ).run

    if response.success?
      json = ActiveSupport::JSON.decode(response.body)
      common_id = json.try(:[], 'goal_id')
    else
      Rails.logger.info(response.body)
      common_id = find_goal(resource.id)
    end

    resource.update_column(
      :common_id, common_id
    ) if common_id.present?

    common_id
  end

  def index_reward(resource)
    return unless resource.id.present?
    unless resource.project.common_id.present?
      resource.project.index_on_common
      resource.project.reload
    end
    return unless resource.project.present?
    return unless resource.project.common_id.present?

    @api_key = proxy_api_key
    uri = services_endpoint[:proxy_service]

    uri.path = if resource.common_id.present?
                 '/v1/projects/' + resource.project.common_id + '/rewards/' + resource.common_id
               else
                 '/v1/projects/' + resource.project.common_id + '/rewards'
               end

    response = request(
      uri.to_s,
      body: {
        reward: resource.common_index
      }.to_json,
      action: (resource.common_id.present? ? :put : :post),
      current_ip: resource.project.user.current_sign_in_ip,
      headers: {'Content-Type' => 'application/json'}
    ).run

    if response.success?
      json = ActiveSupport::JSON.decode(response.body)
      common_id = json.try(:[], 'reward_id')
    else
      Rails.logger.info(response.body)
      common_id = find_reward(resource.id)
    end

    resource.update_column(
      :common_id, common_id
    ) if common_id.present?

    common_id
  end

  def finish_project(resource)
    return unless resource.id.present?
    unless resource.common_id.present?
      resource.index_on_common
      resource.reload
    end

    @api_key = common_api_key
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

    common_id
  end

  def chargeback_payment(payment_uuid)
    @api_key = common_api_key
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
    @api_key = common_api_key
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

  def restore_subscription(resource)
    @api_key = common_api_key
    uri = services_endpoint[:payment_service]
    uri.path = '/rpc/restore_subscription'
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

  def refund_subscription_payment(resource)
    @api_key = common_api_key
    uri = services_endpoint[:payment_service]
    uri.path = '/rpc/refund_subscription_payment'
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
      h.merge!({ 'X-Forwarded-For' => (current_ip||'127.0.0.1') })
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

  private

  def proxy_api_key
    @proxy_api_key ||= CatarseSettings[:common_proxy_api_key]
  end

  def common_api_key
    @common_api_key ||= CatarseSettings[:common_api_key]
  end
end
