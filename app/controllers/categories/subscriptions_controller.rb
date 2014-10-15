class Categories::SubscriptionsController < ApplicationController
  respond_to :html
  before_filter :authenticate_user!

  def create
    parent.users << current_user

    flash[:notice] = I18n.t('explore.index.success_follow', name: parent.name_pt)
    redirect_to explore_path(anchor: "by_category_id/#{parent.id}")
  end

  def destroy
    parent.users.delete(current_user)

    flash[:notice] = I18n.t('explore.index.success_unfollow', name: parent.name_pt)
    redirect_to explore_path(anchor: "by_category_id/#{parent.id}")
  end

  protected

  def parent
    @category ||= Category.find params[:id]
  end
end
