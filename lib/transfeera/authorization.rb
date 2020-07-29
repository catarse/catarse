# frozen_string_literal: true
require 'net/http'

module Transfeera
    class Authorization
        def self.request()
            login_url = CatarseSettings[:transfeera_login_url]

            payload = {
                grant_type: 'client_credentials',
                client_id: CatarseSettings[:transfeera_client_id],
                client_secret: CatarseSettings[:transfeera_client_secret]
            }

            headers = {
                'Content-Type' => 'application/json'
            }

            JSON.parse(Net::HTTP.post(URI(login_url), payload.to_json, headers).body).to_h
        end
    end
end