class BackersController < ApplicationController
  inherit_resources
  defaults resource_class: Backer, collection_name: 'backs', instance_name: 'back'
  belongs_to :user
  actions :index
  respond_to :json, only: [:index]

  def index
    index! do |format|
      format.json{ return render json: @backs.includes(:user, :reward, project: [:user, :category, :project_total]).to_json({include_project: true, can_manage: (can? :manage, @user)}) }
      format.html{ return render nothing: true, status: 404 }
    end
  end
  
  def request_refund
    back = Backer.find(params[:id])

    authorize! :request_refund, back

    if can?(:request_refund, back) && back.can_request_refund?
      back.request_refund!
      flash[:notice] = I18n.t('credits.index.refunded')      
    end

    redirect_to user_path(parent, anchor: 'credits')      
    # render json: {status: status, credits: current_user.reload.display_credits}
  end  

  protected
  def collection
    @backs = end_of_association_chain.avaiable_to_count.order("confirmed_at DESC")
    @backs = @backs.not_anonymous unless @user == current_user or (current_user and current_user.admin)
    @backs = @backs.page(params[:page]).per(10)
  end
end
