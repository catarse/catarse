class Projects::ContributionsController < ApplicationController
  inherit_resources
  actions :index, :show, :new, :update, :review, :create, :credits_checkout
  skip_before_filter :force_http, only: [:create, :edit, :update, :credits_checkout]
  skip_before_filter :verify_authenticity_token, only: [:moip]
  has_scope :available_to_count, type: :boolean
  has_scope :with_state
  has_scope :page, default: 1
  load_and_authorize_resource except: [:index]
  belongs_to :project
  before_filter :detect_old_browsers, only: [:new, :create]

  def update
    resource.update_attributes(params[:contribution])
    resource.update_user_billing_info
    render json: {message: 'updated'}
  end

  def index
    render collection
  end

  def show
    @title = t('projects.contributions.show.title')
  end

  def new
    unless parent.online?
      flash[:failure] = t('projects.back.cannot_back')
      return redirect_to :root
    end

    @create_url = ::Configuration[:secure_review_host] ?
      project_contributions_url(@project, {host: ::Configuration[:secure_review_host], protocol: 'https'}) :
      project_contributions_path(@project)

    @title = t('projects.contributions.new.title', name: @project.name)
    @contribution = @project.contributions.new(user: current_user)
    empty_reward = Reward.new(minimum_value: 0, description: t('projects.contributions.new.no_reward'))
    @rewards = [empty_reward] + @project.rewards.remaining.order(:minimum_value)

    # Select
    if params[:reward_id] && (@selected_reward = @project.rewards.find params[:reward_id]) && !@selected_reward.sold_out?
      @contribution.reward = @selected_reward
      @contribution.value = "%0.0f" % @selected_reward.minimum_value
    end
  end

  def create
    @title = t('projects.contributions.create.title')
    @contribution.user = current_user
    @contribution.reward_id = nil if params[:contribution][:reward_id].to_i == 0
    create! do |success,failure|
      failure.html do
        flash[:failure] = t('projects.contributions.review.error')
        return redirect_to new_project_contribution_path(@project)
      end
      success.html do
        resource.update_current_billing_info
        flash[:notice] = nil
        session[:thank_you_contribution_id] = @contribution.id
        return redirect_to edit_project_contribution_path(project_id: @project.id, id: @contribution.id)
      end
    end
    @thank_you_id = @project.id
  end

  def credits_checkout
    if current_user.credits < @contribution.value
      flash[:failure] = t('projects.contributions.checkout.no_credits')
      return redirect_to new_project_contribution_path(@contribution.project)
    end

    unless @contribution.confirmed?
      @contribution.update_attributes({ payment_method: 'Credits' })
      @contribution.confirm!
    end
    flash[:success] = t('projects.contributions.checkout.success')
    redirect_to project_contribution_path(project_id: parent.id, id: resource.id)
  end

  protected
  def collection
    @contributions ||= apply_scopes(end_of_association_chain).available_to_display.order("confirmed_at DESC").per(10)
  end
end
