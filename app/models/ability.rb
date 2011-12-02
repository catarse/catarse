class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    
    if user.admin?
      can :manage, :all
    elsif user.projects.present? or user.manages_projects.present?
      can :manage, Project do |project|
        user.manages_projects.include?(project) or project.user == user
      end
      can :manage, Reward do |reward|
        user.manages_projects.include?(reward.project) or reward.project.user == user
      end      
    else
      can :read, :all
    end
  end
end
