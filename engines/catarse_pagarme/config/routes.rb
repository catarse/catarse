# frozen_string_literal: true

CatarsePagarme::Engine.routes.draw do
  resources :pagarme, only: [], path: "payment/pagarme" do

    member do
      get  :slip_data, to: 'slip#slip_data'
      get  :second_slip, to: 'slip#update'
      get  :get_installment, to: 'credit_cards#get_installment_json'
      get  :get_encryption_key, to: 'credit_cards#get_encryption_key_json'
      post :pay_credit_card, to: 'credit_cards#create'
      post :pay_slip, to: 'slip#create'
    end

    collection do
      post :ipn, to: 'notifications#create'
    end

  end
end
