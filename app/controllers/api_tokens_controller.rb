# coding: utf-8
class ApiTokensController < ApplicationController
  def show
    unless CatarseSettings[:api_host].present?
      return render json: {error: "you need to have CatarseSettings[:api_host] configured to get an API token"}, status: 500
    end

    unless current_user.present?
      return render json: {error: "only authenticated users can request the API token"}, status: 401
    end
    
    render json: httparty.post("#{CatarseSettings[:api_host]}/postgrest/tokens", body: {id: current_user.id.to_s, pass: current_user.authentication_token}.to_json, options: {headers: { 'Content-Type' => 'application/json' }}).body
  end

  def httparty
    HTTParty
  end
end

