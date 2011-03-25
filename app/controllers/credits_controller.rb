# coding: utf-8
class CreditsController < ApplicationController
  def index
    return unless require_login
    @title = "Meus créditos"
    @refund_backs = current_user.backs.confirmed.can_refund.within_refund_deadline.order(:created_at).all
  end
  def refund
    backer = Backer.find params[:backer_id]
    def error(message); render :json => { :ok => false, :backer_id => backer.id, :message => message }; end;
    return error("Você precisa estar logado para realizar esta ação.") unless current_user
    return error("Este apoio já foi estornado.") if backer.refunded
    return error("Você já solicitou estorno para este apoio.") if backer.requested_refund
    return error("Este apoio não pode ser estornado.") unless backer.can_refund
    return error("Você não possui créditos o suficiente para realizar este estorno.") unless current_user.credits >= backer.value
    current_user.update_attribute :credits, current_user.credits - backer.value
    backer.update_attribute :requested_refund, true
    render :json => { :ok => true, :backer_id => backer.id }
  end
end
