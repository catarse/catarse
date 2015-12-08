# coding: utf-8
class ApiTokensController < ApplicationController
  def show
    unless CatarseSettings[:api_host].present? && CatarseSettings[:jwt_secret].present?
      return render json: {error: "you need to have api_host and jwt_secret configured to get an API token"}, status: 500
    end

    unless current_user.present?
      return render json: {error: "only authenticated users can request the API token"}, status: 401
    end

    render json: {token: jwt}, status: 200
  end

  def jwt
    @jwt ||= JsonWebToken.sign(claims, key: CatarseSettings[:jwt_secret])
  end

  def claims
    { role: current_user.admin ? 'admin' : 'web_user', user_id: current_user.id.to_s }
  end

end

