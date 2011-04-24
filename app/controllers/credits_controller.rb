# coding: utf-8
class CreditsController < ApplicationController
  def index
    return unless require_login
    @title = t('credits.title')
    @refund_backs = current_user.backs.confirmed.can_refund.within_refund_deadline.order(:created_at).all
  end
  def refund
    def error(message); render :json => { :ok => false, :backer_id => @backer.id, :credits => current_user.display_credits, :message => message }; end;
    @backer = Backer.find params[:backer_id]
    return error(t('require_login')) unless current_user
    return error(t('credits.refund.refunded')) if @backer.refunded
    return error(t('credits.refund.requested_refund')) if @backer.requested_refund
    return error(t('credits.refund.cannot_refund')) unless @backer.can_refund
    return error(t('credits.refund.no_credits')) unless current_user.credits >= @backer.value
    @backer.update_attribute :requested_refund, true
    current_user.update_attribute :credits, current_user.credits - @backer.value
    current_user.reload
    render :json => { :ok => true, :backer_id => @backer.id, :credits => current_user.display_credits }
  rescue
    return error(t('credits.refund.error'))
  end
end
