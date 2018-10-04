# coding: utf-8
# frozen_string_literal: true

class ApiTokensController < ApplicationController
  TOKEN_TTL = 1.hour
  before_filter :set_cache_headers

  def common_proxy
    proxy_api_key = CatarseSettings[:common_proxy_api_key]
    unless proxy_api_key.present?
      return render json: { error: 'you need to have common_proxy_api_key setted' }, status: 500
    end

    unless user_signed_in?
      return render json: { error: 'only authenticated users can request the common proxy API token' }, status: 401
    end

    common_wrapper = CommonWrapper.new

    render json: { token: common_wrapper.temp_login_api_key(current_user) }, status: 200
  end

  def common
    unless CatarseSettings[:common_api_key]
      return render json: { error: 'you need to have common_api_key setted' }, status: 500
    end

    unless user_signed_in?
      return render json: { error: 'only authenticated users can request the common API token' }, status: 401
    end

    common_wrapper = CommonWrapper.new

    render json: { token: common_wrapper.user_api_key(current_user) }, status: 200
  end

  def show
    unless CatarseSettings[:api_host].present? && CatarseSettings[:jwt_secret].present?
      return render json: { error: 'you need to have api_host and jwt_secret configured to get an API token' }, status: 500
    end

    unless user_signed_in?
      return render json: { error: 'only authenticated users can request the API token' }, status: 401
    end

    api_wrapper = ApiWrapper.new(current_user)

    expires_in TOKEN_TTL, public: false
    render json: { token: api_wrapper.jwt }, status: 200
  end

  private

  def set_cache_headers
    response.headers['Cache-Control'] = 'no-cache, no-store'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end
end
