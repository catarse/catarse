class UsersController < ApplicationController
  inherit_resources
  actions :show
  can_edit_on_the_spot
  def show
    show!{
      return redirect_to(user_path(@user.primary)) if @user.primary
      @title = "#{@user.display_name}"
      @backs = @user.backs.confirmed.order(:confirmed_at)
      @projects = @user.projects.order("updated_at DESC")
      @projects = @projects.visible unless @user == current_user
    }
  end
end

