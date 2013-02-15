# coding: utf-8
class Ability
  include CanCan::Ability

  def initialize(current_user)
    current_user ||= User.new

    can :read, :all

    # NOTE: Update authorizations
    can :access, :updates do |update|
      update.project.user_id == current_user.id
    end


    # NOTE: Project authorizations
    can :create, :projects if current_user.persisted?

    can :update, :projects, :about do |project|
      project.user == current_user && project.online?
    end

    can :update, :projects, [:about, :video_url, :uploaded_image ] do |project|
      project.user == current_user && ( project.waiting_funds? || project.successful? || project.failed? )
    end

    can :update, :projects do |project|
      project.user == current_user && ( project.draft? || project.rejected? )
    end


    # NOTE: Reward authorizations
    can :create, :rewards do |reward|
      reward.project.user == current_user
    end

    can :destroy, :rewards do |reward|
      reward.backers.empty? && reward.project.user == current_user
    end

    can :update, :rewards do |reward|
      reward.backers.empty? && reward.project.user == current_user
    end

    can :update, :rewards, [:description, :maximum_backers] do |reward|
      reward.project.user == current_user
    end

    # NOTE: User authorizations
    can [:update, :request_refund, :credits, :manage], :users  do |user|
      current_user == user
    end

    can :update, :users, :admin do |user|
      current_user.admin
    end

    # NOTE: Backer authorizations
    cannot :show, :backers
    can :create, :backers if current_user.persisted?
    can [ :request_refund, :credits_checkout, :show ], :backers do |backer|
      backer.user == current_user
    end

    # NOTE: When admin can access all things ;)
    can :access, :all if current_user.admin?
  end
end
