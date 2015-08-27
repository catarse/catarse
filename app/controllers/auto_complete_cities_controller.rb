class AutoCompleteCitiesController < ApplicationController
  respond_to :html

  def index
    @cities = City.where("unaccent(upper(name)) LIKE ('%'||unaccent(upper(?))||'%')", params[:pg_search]).limit(params[:limit])
    return render partial: 'city', collection: @cities, layout: false
  end
end
