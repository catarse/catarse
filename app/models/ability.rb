class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    
    if user.admin?
      can :manage, :all
    elsif not user.manages_projects.empty?
      can :manage, Project do |project|
        user.manages_projects.include? project
      end
      can :manage, Reward do |reward|
        user.manages_projects.include? reward.project
      end      
    else
      can :read, :all
    end
  end
end
