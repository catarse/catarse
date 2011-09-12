class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    
    if user.admin?
      can :manage, :all
    else
      can :read, :all
      can :manage, Project, :user_id => user.id
      can :manage, Reward do |reward|
        user.projects.include?(reward.project)
      end
    end
  end
end
