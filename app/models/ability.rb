# coding: utf-8
class Ability
  include CanCan::Ability

  def initialize(current_user, options = {})
    current_user ||= User.new

    can :read, :all

    # NOTE: Update authorizations
    can :access, :updates do |update|
      update.project.user_id == current_user.id
    end
    can :see, :updates do |update|
      !update.exclusive || !current_user.backs.confirmed.where(project_id: update.project.id).empty?
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

    can [:update, :sort], :rewards, [:description, :maximum_backers] do |reward|
      reward.project.user == current_user
    end

    can [:update, :destroy], :rewards do |reward|
      reward.backers.in_time_to_confirm.empty? && reward.backers.confirmed.empty? && reward.project.user == current_user
    end

    can :update, :rewards, :days_to_delivery do |reward|
      reward.project.user == current_user && !reward.project.successful? && !reward.project.failed?
    end

    # NOTE: User authorizations
    can :set_email, :users do |user|
      current_user.persisted?
    end

    can [:update, :credits, :manage, :update_password, :update_email], :users  do |user|
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

    # Channel authorizations
    # Due to previous abilities, first I activate all things
    # and in the final I deactivate unnecessary abilities.
    can :create, :channels_subscribers if current_user.persisted?
    can :destroy, :channels_subscribers do |cs|
      cs.user == current_user
    end

    if current_user.trustee?

      can :access, :all
      cannot :access, :projects
      cannot :access, :rewards

      can :create, :projects
      can :access, :projects do |project|
        current_user.channels_projects.exists?(project)
      end


      can :access, :rewards do |reward|
        current_user.channels_projects.exists?(reward.project)
      end


      # For the access, :all
      # we're removing the ability to update users at all, but
      cannot [:update, :destroy], :users

      # He can update himself
      can :update, :users do |user|
        user == current_user
      end

      # Nobody can destroy projects.
      cannot :destroy, :projects
    end

    # A trustee cannot access the adm/ path
    # He can only do this if he is an admin too.
    case options[:namespace]
      when "Adm"
        if current_user.trustee? && !current_user.admin?
          cannot :access, :all
        end
      else
    end



    # NOTE: admin can access everything.
    # It's the last ability to override all previous abilities.
    can :access, :all if current_user.admin?


  end
end
