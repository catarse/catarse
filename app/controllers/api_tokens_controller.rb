# coding: utf-8
class ApiTokensController < ApplicationController
  TOKEN_TTL = 1.hour

  def show
    unless CatarseSettings[:api_host].present? && CatarseSettings[:jwt_secret].present?
      return render json: {error: "you need to have api_host and jwt_secret configured to get an API token"}, status: 500
    end

    unless current_user.present?
      return render json: {error: "only authenticated users can request the API token"}, status: 401
    end

    api_wrapper = ApiWrapper.new(current_user)

    expires_in TOKEN_TTL, public: false
    render json: {token: api_wrapper.jwt}, status: 200
  end
end
