class CuratedPageController < ApplicationController
  inherit_resources
  load_and_authorize_resource

  def index
    @curated_pages = CuratedPage.all
  end
  
  def show
    @curated_page = CuratedPage.find_by_permalink(params[:permalink])
    show!
  end
end
