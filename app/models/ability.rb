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
