class ChannelsSubscriberPolicy < ApplicationPolicy
  def show?
    done_by_owner_or_admin?
  end

  def destroy?
    done_by_owner_or_admin?
  end
end

