class Home::BannersController < ApplicationController
    respond_to :json

    def update

        authorize resource

        resource.title = params.try(:title) || ''
        resource.subtitle = params.try(:title) || ''
        resource.cta = params.try(:cta) || ''
        resource.link = params.try(:link) || ''
        resource.image = params.try(:image) || ''
        resource.save
        
        render json: { success: 'ok'}, status: 200
    end

    def index
        render json: { data: HomeBanner.all }
    end

    private

    def resource
        HomeBanner.find params[:id]
    end
end
