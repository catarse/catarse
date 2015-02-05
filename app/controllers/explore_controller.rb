class ExploreController < ApplicationController
  layout 'catarse_bootstrap'
  def index
    @title = t('explore.title')

    @categories = Category.with_projects.order(:name_pt).all
  end
end
