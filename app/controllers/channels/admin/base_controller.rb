module Channels::Admin
  def self.policy_class
    ChannelOwnerPolicy
  end

  class BaseController < ::Admin::BaseController
    inherit_resources
    layout 'catarse_bootstrap'

    before_filter do
      authorize Channels::Admin, :access?
    end

    def policy(record)
      Channels::Admin.policy_class.new(current_user, record, channel)
    end
  end
end

