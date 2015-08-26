class AutoCompleteCitiesController < ApplicationController
  respond_to :html

  def index
    @cities = City.where("lower(name) LIKE ?", "%#{params[:pg_search].downcase}%").limit(params[:limit])
    return render partial: 'city', collection: @cities, layout: false
  end
end
