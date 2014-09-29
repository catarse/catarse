class Users::CreditCardsController < ApplicationController
  after_filter :verify_authorized

  inherit_resources
  actions :destroy
  belongs_to :user

  def destroy
    authorize resource
    resource.cancel_subscription
    destroy! { user_path(parent, anchor: 'credit_cards') }
  end
end

