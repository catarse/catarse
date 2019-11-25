class Home::BannersController < ApplicationController
    respond_to :json

    def update
        authorize resource
        
        if resource.update(permitted_params)
            render json: { success: 'ok'}, status: 200
        else
            render json: resource.errors, status: 401
        end
    end

    def index
        render json: { data: HomeBanner.all.order(:id) }, status: 200
    end

    private

    def resource
        HomeBanner.find params[:id]
    end

    def permitted_params
        banner_params.permit(:title, :subtitle, :cta, :link, :image)
    end

    def banner_params
        params[:banner]
    end

end
