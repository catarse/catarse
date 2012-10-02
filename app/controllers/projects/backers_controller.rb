class Projects::BackersController < ApplicationController
  inherit_resources
  actions :index, :new, :update_info
  before_filter :load_project

  def update_info
    return unless require_login
    @backer = current_user.backs.find params[:id]
    @backer.update_attributes(params[:backer])
    render :json => {:message => 'updated'}
  end

  def index
    @backers = @project.backers.confirmed.order("confirmed_at DESC").page(params[:page]).per(10)
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

  def review
    return unless require_login

    @title = t('projects.backers.review.title')
    params[:backer][:reward_id] = nil if params[:backer][:reward_id] == '0'
    params[:backer][:user_id] = current_user.id
    @project = Project.find params[:project_id]
    @backer = @project.backers.new(params[:backer])

    unless @backer.save
      flash[:failure] = t('projects.backers.review.error')
      return redirect_to new_project_backer_path(@project)
    end

    session[:thank_you_id] = @project.id
  end

  def checkout
    return unless require_login
    backer = current_user.backs.find params[:id]
    if params[:payment_method_url].present?
      current_user.update_attributes params[:user]
      current_user.reload
      return redirect_to params[:payment_method_url]
    else 
      if backer.credits
        if current_user.credits < backer.value
          flash[:failure] = t('projects.backers.checkout.no_credits')
          return redirect_to new_project_backer_path(backer.project)
        end
        unless backer.confirmed
          current_user.credits = (current_user.credits - backer.value)
          current_user.save
          backer.update_attributes({ payment_method: 'Credits' })
          backer.confirm!
        end
        flash[:success] = t('projects.backers.checkout.success')
        redirect_to thank_you_path
      end
    end
  end



  private

  def load_project
    @project = Project.find params[:project_id]
  end
end
