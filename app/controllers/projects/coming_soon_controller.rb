# frozen_string_literal: true

module Projects
  class ComingSoonController < ApplicationController
    def activate
      @integration = ProjectIntegration.new
      @integration.attributes = attributes
      @integration.project = parent
      authorize @integration

      if @integration.save
        respond_to { |format| format.json { render json: @integration } }
      else
        respond_to { |format| format.json { render status: :bad_request, json: @integration.errors } }
      end
    end

    def deactivate
      authorize resource, policy_class: ProjectIntegrationPolicy

      resource.destroy

      respond_to do |format|
        format.json { render json: { success: 'OK' } }
      end
    end

    private

    def attributes
      {
        name: 'COMING_SOON_LANDING_PAGE',
        data: {
          draft_url: "#{parent.permalink.parameterize.tr('-', '_')}_#{SecureRandom.hex(4)}"
        }
      }
    end

    def resource
      @resource ||= parent.integrations.coming_soon.first!
    end

    def parent
      @parent ||= Project.find params[:id]
    end
  end
end
