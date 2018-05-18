# frozen_string_literal: true

class Admin::ContributionsController < Admin::BaseController
  layout 'catarse_bootstrap'

  # batch_chargeback is used as external action in catarse.js
  def batch_chargeback
    authorize Admin, :batch_chargeback?
    # TODO: move the chargeback task to queue 
    # to avoid timeouts when using a lot of ids
    collection_for_chargeback.each do |contribution_detail|
      payment = contribution_detail.payment
      payment.chargeback
    end

    render json: { payment_ids: collection_for_chargeback.pluck(:id) }
  end

  # gateway_refund is used as external action in catarse.js
  def gateway_refund
    resource.direct_refund
    respond_to do |format|
      format.html do
        return redirect_to admin_contributions_path(params[:local_params])
      end
      format.json do
        return render json: []
      end
    end
  end

  protected

  def resource
    ContributionDetail.find_by_id params[:id]
  end

  def collection_for_chargeback
    ContributionDetail.where(gateway_id: params[:gateway_payment_ids], gateway: 'Pagarme').where('gateway_id is not null')
  end
end
