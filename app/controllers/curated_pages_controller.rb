class CuratedPagesController < ApplicationController
  inherit_resources
  load_and_authorize_resource

  def index
    @curated_pages = current_site.curated_pages.all
  end
  
  def show
    @curated_page = CuratedPage.find_by_permalink(params[:permalink])
    @title = @curated_page.name
    show!
  end
end
