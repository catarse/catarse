# frozen_string_literal: true

Rails.application.routes.draw do
  mount CatarsePagarme::Engine => "/", as: :catarse_pagarme
end
