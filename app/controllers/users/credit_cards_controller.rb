# frozen_string_literal: true

class Users::CreditCardsController < ApplicationController
  after_filter :verify_authorized

  inherit_resources
  actions :destroy
  belongs_to :user

  def destroy
    authorize resource
    destroy! { edit_user_path(parent, anchor: 'settings') }
  end
end
