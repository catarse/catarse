class ChannelOwnerPolicy < ApplicationPolicy
  def access?
    is_admin? || is_channel_admin?
  end
end
