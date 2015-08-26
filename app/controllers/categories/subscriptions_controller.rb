class Categories::SubscriptionsController < ApplicationController
  respond_to :html
  before_filter :authenticate_user!

  def create
    parent.users << current_user
    redirect_with_flash 'pages.explore.success_follow'
  end

  def destroy
    parent.users.delete(current_user)
    redirect_with_flash 'pages.explore.success_unfollow'
  end

  protected

  def redirect_with_flash notice_locale_key
    flash[:notice] = I18n.t(notice_locale_key, name: parent.name_pt)
    redirect_to explore_path(anchor: "by_category_id/#{parent.id}")
  end

  def parent
    @category ||= Category.find params[:id]
  end
end
