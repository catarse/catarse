module Admin
  def self.policy_class
    AdminPolicy
  end

  class BaseController < ApplicationController
    inherit_resources

    before_filter do
      authorize Admin, :access?
    end

    def update
      update! do |format|
        if resource.errors.empty?
          format.json { respond_with_bip(resource) }
        else
          format.html { render :edit }
          format.json { respond_with_bip(resource) }
        end
      end
    end

    def policy(record)
      Admin.policy_class.new(current_user, record)
    end
  end
end

