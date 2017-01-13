# coding: utf-8
class ApiTokensController < ApplicationController
  TOKEN_TTL = 1.hour
  before_filter :set_cache_headers

  def show
    unless CatarseSettings[:api_host].present? && CatarseSettings[:jwt_secret].present?
      return render json: {error: "you need to have api_host and jwt_secret configured to get an API token"}, status: 500
    end

    unless user_signed_in?
      return render json: {error: "only authenticated users can request the API token"}, status: 401
    end

    api_wrapper = ApiWrapper.new(current_user)

    expires_in TOKEN_TTL, public: false
    render json: {token: api_wrapper.jwt}, status: 200
  end

  private

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
