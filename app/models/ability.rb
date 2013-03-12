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

    can :update, :projects, [:about, :video_url, :uploaded_image, :headline ] do |project|
      project.user == current_user && ( project.online? || project.waiting_funds? || project.successful? || project.failed? )
    end

    can :update, :projects do |project|
      project.user == current_user && ( project.draft? || project.rejected? )
    end


    # NOTE: Reward authorizations
    can :create, :rewards do |reward|
      reward.project.user == current_user
    end

    can :update, :rewards, [:description, :maximum_backers] do |reward|
      reward.project.user == current_user
    end

    can [:update, :destroy], :rewards do |reward|
      reward.backers.in_time_to_confirm.empty? && reward.backers.confirmed.empty? && reward.project.user == current_user
    end

    # NOTE: User authorizations
    can :set_email, :users do |user|
      current_user.persisted?
    end

    can [:update, :request_refund, :credits, :manage, :update_email], :users  do |user|
      current_user == user
    end

    can :update, :users, :admin do |user|
      current_user.admin
    end

    # NOTE: Backer authorizations
    cannot :show, :backers
    can :create, :backers if current_user.persisted?
    can [ :request_refund, :credits_checkout, :show, :update_info ], :backers do |backer|
      backer.user == current_user
    end

    # NOTE: When admin can access all things ;)
    can :access, :all if current_user.admin?
  end
end
