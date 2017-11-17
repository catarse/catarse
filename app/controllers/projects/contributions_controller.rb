# frozen_string_literal: true

class Projects::ContributionsController < ApplicationController
  DEFAULT_AMOUNT = 10
  inherit_resources
  actions :index, :show, :new, :update, :review, :create
  skip_before_filter :verify_authenticity_token, only: [:moip]
  after_filter :verify_authorized, except: [:index]
  belongs_to :project
  before_filter :detect_old_browsers, only: %i[new create]

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
    render json: { message: 'updated' }
  end

  def show
    authorize resource
    @title = t('projects.contributions.show.title')
  end

  def new
    @contribution = Contribution.new(project: parent, value: (params[:amount].presence || DEFAULT_AMOUNT).to_i)
    authorize @contribution

    @title = t('projects.contributions.new.title', name: @project.name)
  end

  def create
    @title = t('projects.contributions.create.title')
    @contribution = parent.contributions.new.localized
    @contribution.user = current_user
    @contribution.value = permitted_params[:value]
    @contribution.origin = Origin.process_hash(referral)
    @contribution.reward_id = (params[:contribution][:reward_id].to_i == 0 ? nil : params[:contribution][:reward_id])
    @contribution.shipping_fee_id = (params[:contribution][:shipping_fee_id].to_i == 0 ? nil : params[:contribution][:shipping_fee_id])
    authorize @contribution
    @contribution.update_current_billing_info
    create! do |success, failure|
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

  def second_slip
    authorize resource
    if resource.reward.try(:sold_out?)
      flash[:alert] = t('.reward_sold_out')
      return redirect_to new_project_contribution_path(resource.project)
    end
    redirect_to resource.details.ordered.first.second_slip_path
  end

  def receipt
    authorize resource
    project = resource.project
    template = project.successful? ? 'contribution_project_successful' : 'confirm_contribution'
    render "user_notifier/mailer/#{template}", locals: { contribution: resource }, layout: 'layouts/email'
  end

  def toggle_delivery
    authorize resource
    if resource.delivery_status == 'received'
      resource.delivery_status = resource.reward_sent_at.nil? ? 'undelivered' : 'delivered'
      resource.reward_received_at = nil
    else
      resource.delivery_status = 'received'
      resource.reward_received_at = Time.current
    end
    resource.save!(validate: false)
    render nothing: true
  end

  def update_status
    project = Project.find params['project_id']
    authorize project, :update?
    contributions = project.contributions.where(id: params['contributions'])
    if params[:delivery_status] == 'delivered'
      contributions.update_all(reward_sent_at: Time.current)
      send_delivery_notification contributions, 'delivered', 'delivery_confirmed'
    elsif params[:delivery_status] == 'error'
      send_delivery_notification contributions, 'error', 'delivery_error'
    end
    contributions.update_all(delivery_status: params['delivery_status'])

    respond_to do |format|
      format.json { render json: { success: 'OK' } }
    end
  end

  def toggle_anonymous
    authorize resource
    resource.toggle!(:anonymous)
    render nothing: true
  end

  protected

  def send_delivery_notification(contributions, status, template_name)
    contributions.where.not(delivery_status: status).each do |contribution|
      Notification.create!(user_id: contribution.user_id, user_email: contribution.user.email, template_name: template_name, metadata: { locale: 'pt', message: params['message'], from_name: "#{contribution.project.user.display_name} via Catarse", from_email: contribution.project.user.email, associations: { project_id: contribution.project.id, contribution_id: contribution.id } }.to_json)
    end
  end

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
