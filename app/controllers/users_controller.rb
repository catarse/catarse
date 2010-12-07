class UsersController < ApplicationController
  inherit_resources
  actions :show
  def show
    show!{ @title = "#{@user.display_name}" }
  end
end
