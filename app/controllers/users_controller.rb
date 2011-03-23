# coding: utf-8
class UsersController < ApplicationController
  inherit_resources
  actions :show
  can_edit_on_the_spot
  before_filter :can_update_on_the_spot?, :only => :update_attribute_on_the_spot
  def show
    show!{
      return redirect_to(user_path(@user.primary)) if @user.primary
      @title = "#{@user.display_name}"
      @backs = @user.backs.confirmed.project_visible.order(:confirmed_at)
      @backs = @backs.not_anonymous unless @user == current_user
      @backs = @backs.all
      @projects = @user.projects.order("updated_at DESC")
      @projects = @projects.visible unless @user == current_user
      @projects = @projects.all
    }
  end
  private
  def can_update_on_the_spot?
    fields = ["email", "name", "bio", "newsletter", "project_updates"]
    def render_error; render :text => 'Você não possui permissão para realizar esta ação.', :status => 422; end
    return render_error unless current_user
    klass, field, id = params[:id].split('__')
    return render_error unless klass == 'user'
    return render_error unless fields.include? field
    user = User.find id
    return render_error unless current_user.id == user.id or current_user.admin
  end
end
