# coding: utf-8
class Ability
  include CanCan::Ability

  def initialize(current_user, options = {})
    current_user ||= User.new

    can :read, :all

    # NOTE: Project authorizations
    can :update, :projects, [:about, :video_url, :uploaded_image, :headline ] do |project|
      project.user == current_user && ( project.online? || project.waiting_funds? || project.successful? || project.failed? )
    end

    can :update, :projects do |project|
      project.user == current_user && ( project.draft? || project.rejected? || project.in_analysis? )
    end

    # NOTE: Reward authorizations
    can :create, :rewards do |reward|
      reward.project.user == current_user
    end

    can [:update, :destroy], :rewards do |reward|
      reward.contributions.with_state('waiting_confirmation').empty? && reward.contributions.with_state('confirmed').empty? && reward.project.user == current_user
    end

    can [:update, :sort], :rewards, [:description, :maximum_contributions] do |reward|
      reward.project.user == current_user
    end

    can :update, :rewards, :days_to_delivery do |reward|
      reward.project.user == current_user && !reward.project.successful? && !reward.project.failed?
    end

    # NOTE: User authorizations
    can :set_email, :users do |user|
      current_user.persisted?
    end

    can [:update, :credits, :manage, :update_password, :update_email, :unsubscribe_notifications], :users  do |user|
      current_user == user
    end

    can :update, :users, :admin do |user|
      current_user.admin
    end

    # NOTE: Contribution authorizations
    cannot :show, :contributions
    can :create, :contributions if current_user.persisted?

    can [ :request_refund, :credits_checkout, :show, :update, :edit], :contributions do |contribution|
      contribution.user == current_user
    end

    cannot :update, :contributions, [:user_attributes, :user_id, :user, :value, :payment_service_fee, :payment_id] do |contribution|
      contribution.user == current_user
    end

    # Channel authorizations
    # Due to previous abilities, first I activate all things
    # and in the final I deactivate unnecessary abilities.
    can :create, :channels_subscribers if current_user.persisted?
    can :destroy, :channels_subscribers do |cs|
      cs.user == current_user
    end

    can [:update, :edit], :channels do |c|
      c == current_user.channel
    end

    if options[:channel]  && options[:channel] == current_user.channel
      can :access, :admin
      can :access, :channel_posts
      can :access, :admin_projects_path
      can :access, :edit_channels_profile_path
      can :access, :channels_admin_followers_path
      can :access, :channels_admin_posts_path
    end

    # NOTE: admin can access everything.
    # It's the last ability to override all previous abilities.
    can :access, :all if current_user.admin?
  end
end
