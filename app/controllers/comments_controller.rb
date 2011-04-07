# coding: utf-8
class CommentsController < ApplicationController
  inherit_resources
  actions :index, :show, :create, :destroy
  respond_to :json
  def create
    return render :text => "Você deve estar logado para realizar esta ação.", :status => 422 unless current_user
    @comment = Comment.new(params[:comment])
    @comment.user = current_user
    create!
  end
  def destroy
    @comment = Comment.find params[:id]
    return render :text => "Você não tem permissão para realizar esta ação.", :status => 422 unless current_user and (current_user == @comment.user or current_user.admin)
    destroy!
  end
end
