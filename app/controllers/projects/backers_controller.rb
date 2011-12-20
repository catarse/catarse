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

  def checkout
    return unless require_login

    @title = t('projects.backers.checkout.title')
    params[:backer][:reward_id] = nil if params[:backer][:reward_id] == '0'
    params[:backer][:user_id] = current_user.id
    @project = Project.find params[:project_id]
    @backer = @project.backers.new(params[:backer])

    unless @backer.save
      flash[:failure] = t('projects.backers.checkout.error')
      return redirect_to new_project_backer_path(@project)
    end

    session[:thank_you_id] = @project.id
  end

  private

  def load_project
    @project = Project.find params[:project_id]
  end
end