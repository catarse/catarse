class Projects::ContributionsController < ApplicationController
  DEFAULT_AMOUNT = 10
  inherit_resources
  actions :index, :show, :new, :update, :review, :create
  skip_before_filter :verify_authenticity_token, only: [:moip]
  after_filter :verify_authorized, except: [:index]
  belongs_to :project
  before_filter :detect_old_browsers, only: [:new, :create]

  helper_method :engine

  def edit
    authorize resource
    if resource.reward.try(:sold_out?)
      flash[:alert] = t('.reward_sold_out')
      return redirect_to new_project_contribution_path(@project)
    end
    return render :existing_payment if resource.payments.exists?
  end

  def update
    authorize resource
    resource.update_attributes(permitted_params)
    resource.update_user_billing_info
    render json: {message: 'updated'}
  end

  def show
    authorize resource
    @title = t('projects.contributions.show.title')
  end

  def new
    @contribution = Contribution.new(project: parent, value: (params[:amount].presence || DEFAULT_AMOUNT).to_i)
    authorize @contribution

    @title = t('projects.contributions.new.title', name: @project.name)
    load_rewards

    if params[:reward_id] && (@selected_reward = @project.rewards.find params[:reward_id]) && !@selected_reward.sold_out?
      @contribution.reward = @selected_reward
      @contribution.value = "%0.0f" % @selected_reward.minimum_value
    end
  end

  def create
    @title = t('projects.contributions.create.title')
    @contribution = parent.contributions.new.localized
    @contribution.user = current_user
    @contribution.value = permitted_params[:value]
    @contribution.origin = Origin.process_hash(referral)
    @contribution.reward_id = (params[:contribution][:reward_id].to_i == 0 ? nil : params[:contribution][:reward_id])
    authorize @contribution
    @contribution.update_current_billing_info
    create! do |success,failure|
      failure.html do
        flash[:alert] = resource.errors.full_messages.to_sentence
        load_rewards
        render :new
      end
      success.html do
        flash[:notice] = nil
        session[:thank_you_contribution_id] = @contribution.id
        return redirect_to edit_project_contribution_path(project_id: @project.id, id: @contribution.id)
      end
    end
    @thank_you_id = @project.id
  end

  def no_account_refund
    authorize resource
  end

  def second_slip
    authorize resource
    redirect_to resource.details.ordered.first.second_slip_path
  end

  def receipt
    authorize resource
    template = resource.project.successful? ? 'contribution_project_successful' : 'confirm_contribution'
    render "user_notifier/mailer/#{template}", locals: { contribution: resource }
  end

  def toggle_anonymous
    authorize resource
    resource.toggle!(:anonymous)
    return render nothing: true
  end

  protected
  def load_rewards
    if @project.rewards.present?
      empty_reward = Reward.new(minimum_value: 0, description: t('projects.contributions.new.no_reward'))
      @rewards = [empty_reward] + @project.rewards.remaining.order(:minimum_value)
    else
      @rewards = []
    end
  end

  def permitted_params
    params.require(:contribution).permit(policy(resource).permitted_attributes)
  end

  def engine
    PaymentEngines.find_engine('Pagarme')
  end
end
