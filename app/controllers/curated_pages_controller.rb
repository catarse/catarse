class CuratedPagesController < ApplicationController
  inherit_resources
  load_and_authorize_resource

  def index
    @curated_pages = curated_pages.all
  end

  def show
    @curated_page = CuratedPage.find_by_permalink(params[:permalink])
    return render_404 unless @curated_page.present?
    @title = @curated_page.name
    show!
  end
end
