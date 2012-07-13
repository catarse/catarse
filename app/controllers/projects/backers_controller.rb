class Projects::BackersController < ApplicationController
  inherit_resources
  actions :index, :new
  before_filter :load_project

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
          current_user.update_attribute :credits, current_user.credits - backer.value
          backer.update_attribute :payment_method, 'Credits'
          backer.confirm!
        end
        flash[:success] = t('projects.backers.checkout.success')
        redirect_to thank_you_path
      else
        begin
          current_user.update_attributes params[:user]
          current_user.reload
          payer = {
            :nome => current_user.full_name,
            :email => current_user.email,
            :logradouro => current_user.address_street,
            :numero => current_user.address_number,
            :complemento => current_user.address_complement,
            :bairro => current_user.address_neighbourhood,
            :cidade => current_user.address_city,
            :estado => current_user.address_state,
            :pais => "BRA",
            :cep => current_user.address_zip_code,
            :tel_fixo => current_user.phone_number
          }
          payment = {
            :valor => "%0.0f" % (backer.value),
            :id_proprio => backer.key,
            :razao => "Apoio para o projeto '#{backer.project.name}'",
            :forma => "BoletoBancario",
            :dias_expiracao => 2,
            :pagador => payer,
            :url_retorno => thank_you_url
          }
          response = MoIP::Client.checkout(payment)
          backer.update_attribute :payment_token, response["Token"]
          session[:_payment_token] = response["Token"]
          redirect_to MoIP::Client.moip_page(response["Token"])
        rescue
          Airbrake.notify({ :error_class => "Checkout MOIP Error", :error_message => "MOIP Error: #{e.inspect}", :parameters => params}) rescue nil
          Rails.logger.info "-----> #{e.inspect}"
          flash[:failure] = t('projects.backers.checkout.moip_error')
          return redirect_to new_project_backer_path(backer.project)
        end
      end
    end
  end



  private

  def load_project
    @project = Project.find params[:project_id]
  end
end
