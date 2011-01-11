class UsersController < ApplicationController
  inherit_resources
  actions :show
  def show
    show!{
      @title = "#{@user.display_name}"
      @backs = @user.backs.confirmed.order(:confirmed_at)
      @projects = @user.projects.visible.order("updated_at DESC")
    }
  end
end
