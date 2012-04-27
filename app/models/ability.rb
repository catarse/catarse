# coding: utf-8
class Ability
  include CanCan::Ability

  def initialize(current_user)
    current_user ||= User.new

    can :read, User
    can :manage, User, :id => current_user.id
    can :request_refund, Backer, :user_id => current_user.id
    can :backs, User
    can :projects, User

    if current_user.admin?
      can :manage, :all
    elsif current_user.projects.present? or current_user.manages_projects.present?
      can :manage, Project do |project|
        current_user.manages_projects.include?(project) or project.user == current_user
      end
      can :manage, Reward do |reward|
        current_user.manages_projects.include?(reward.project) or reward.project.user == current_user
      end
    else
      can :read, :all
    end
  end
end
