class Projects::BackersController < ApplicationController
  inherit_resources
  actions :index, :new
  before_filter :load_project

  def index
    @backers = @project.backers.confirmed.order("confirmed_at DESC").paginate :page => params[:page], :per_page => 10
    render :json => @backers.to_json(:can_manage => can?(:manage, @project))
  end

  def new
    return unless require_login
    unless @project.can_back?
      flash[:failure] = t('projects.back.cannot_back')
      return redirect_to :root
    end
    @title = t('projects.backers.new.title', :name => @project.name)
    @backer = @project.backers.new(:user => current_user)
    empty_reward = Reward.new(:id => 0, :minimum_value => 0, :description => t('projects.backers.new.no_reward'))
    @rewards = [empty_reward] + @project.rewards.order(:minimum_value)
    @reward = @project.rewards.find params[:reward_id] if params[:reward_id]
    @reward = nil if @reward and @reward.sold_out?
    if @reward
      @backer.reward = @reward
      @backer.value = "%0.0f" % @reward.minimum_value
    end
  end

  private

  def load_project
    @project = Project.find params[:project_id]
  end
end