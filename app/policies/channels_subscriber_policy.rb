class ChannelsSubscriberPolicy < ApplicationPolicy
  def show?
    done_by_onwer_or_admin?
  end

  def destroy?
    done_by_onwer_or_admin?
  end
end

