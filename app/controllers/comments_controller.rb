# coding: utf-8
class CommentsController < ApplicationController
  inherit_resources
  actions :index, :show, :create, :destroy
  respond_to :json
  #skip_before_filter :verify_authenticity_token
  def create
    return render :text => "Você deve estar logado para realizar esta ação.", :status => 422 unless current_user
    @comment = Comment.new(params[:comment])
    @comment.user = current_user
    create! do
    end
  end
end
