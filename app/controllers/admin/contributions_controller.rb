# frozen_string_literal: true

class Admin::ContributionsController < Admin::BaseController
  layout 'catarse_bootstrap'

  # batch_chargeback is used as external action in catarse.js
  def batch_chargeback
    # TODO: move the chargeback task to queue 
    # to avoid timeouts when using a lot of ids
    collection.each do |contribution_detail|
      payment = contribution_detail.payment
      payment.chargeback
    end

    render json: { payment_ids: collection.pluck(:id) }
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

  def collection
    ContributionDetail.where(id: params[:payment_ids])
  end
end
