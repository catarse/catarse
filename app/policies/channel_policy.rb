class ChannelPolicy < ApplicationPolicy
  def update?
    done_by_owner_or_admin?
  end

  protected
  def is_owned_by?(user)
    user.present? && record == user.channel
  end
end

