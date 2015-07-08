# coding: utf-8
class ApiTokensController < ApplicationController
  def show
    unless CatarseSettings[:api_host].present?
      return render json: {error: "you need to have CatarseSettings[:api_host] configured to get an API token"}, status: 500
    end

    unless current_user.present?
      return render json: {error: "only authenticated users can request the API token"}, status: 401
    end

    render json: http_auth_response.body, status: http_auth_response.code
  end

  def httparty
    HTTParty
  end

  def http_auth_response
    @http_response ||= httparty.post(
      "#{CatarseSettings[:api_host]}/postgrest/tokens",
      body: {
        id: current_user.id.to_s,
        pass: current_user.authentication_token }.to_json,
      options: {
        headers: {
          'Content-Type' => 'application/json' }}
    )
  end
end

