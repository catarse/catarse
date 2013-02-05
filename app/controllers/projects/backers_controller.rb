class Projects::BackersController < ApplicationController
  inherit_resources
  actions :index, :new, :update_info
  skip_before_filter :force_http, only: [:review, :update_info]
  skip_before_filter :verify_authenticity_token, :only => [:moip]
  belongs_to :project

  def update_info
    return unless require_login
    resource.update_attributes(params[:backer])
    render :json => {:message => 'updated'}
  end

  def index
    @backers = parent.backers.confirmed.order("confirmed_at DESC").page(params[:page]).per(10)
    render :json => @backers.to_json(:can_manage => can?(:update, @project))
  end

  def thank_you
    unless resource.user == current_user
      flash[:failure] = I18n.t('payment_stream.thank_you.error')
      return redirect_to :root
    end
    @title = t('projects.backers.thank_you.title')
  end

  def new
    return unless require_login
    unless parent.can_back?
      flash[:failure] = t('projects.back.cannot_back')
      return redirect_to :root
    end

    @review_url = ::Configuration[:secure_review_host] ?
      review_project_backers_url(@project, {:host => ::Configuration[:secure_review_host], :protocol => 'https'}) :
      review_project_backers_path(@project)

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
    @backer = parent.backers.new(params[:backer])

    unless @backer.save
      flash[:failure] = t('projects.backers.review.error')
      return redirect_to new_project_backer_path(@project)
    end

    @thank_you_id = @project.id
  end

  def credits_checkout
    return unless require_login
    unless resource.user == current_user && resource.credits
      flash[:failure] = t('projects.backers.review.error')
      return redirect_to new_project_backer_path(@project)
    end

    if current_user.credits < @backer.value
      flash[:failure] = t('projects.backers.checkout.no_credits')
      return redirect_to new_project_backer_path(@backer.project)
    end
    unless @backer.confirmed
      @backer.update_attributes({ payment_method: 'Credits' })
      @backer.confirm!
    end
    flash[:success] = t('projects.backers.checkout.success')
    redirect_to thank_you_project_backer_path(project_id: parent.id, id: resource.id)
  end
end
