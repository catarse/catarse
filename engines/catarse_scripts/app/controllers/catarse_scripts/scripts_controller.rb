require_dependency "catarse_scripts/application_controller"

module CatarseScripts
  class ScriptsController < ApplicationController
    before_action :set_script, only: %i[show execute update edit destroy]
    before_action :set_policy
    before_action :process_filters, only: :index
    before_action :load_filter_options, only: :index
    before_action :load_tags, only: %i[index new edit]

    def index
      raise ActionController::RoutingError.new('Not Found') unless @policy.can_read?
      params[:q] = { status_eq: Script.statuses[:pending], s: 'created_at desc' } unless params[:q]
      @q = Script.ransack(params[:q])
      result = @q.result(distinct: true).includes(:creator)
      @pagy, @scripts = pagy(result, items: 20)
    end

    def show
      raise ActionController::RoutingError.new('Not Found') unless @policy.can_read?
    end

    def new
      raise ActionController::RoutingError.new('Not Found') unless @policy.can_create?

      @script = Script.new
    end

    def create
      raise ActionController::RoutingError.new('Not Found') unless @policy.can_create?

      script_params = permitted_params.merge(creator_id: current_user.id, status: :pending)

      @script = Script.new(script_params)
      if @script.save
        redirect_to script_path(@script)
      else
        load_tags
        render 'new'
      end
    end

    def edit
      raise ActionController::RoutingError.new('Not Found') unless @policy.can_update?(@script)
    end

    def update
      raise ActionController::RoutingError.new('Not Found') unless @policy.can_update?(@script)

      if @script.update(permitted_params)
        redirect_to script_path(@script)
      else
        load_tags
        render 'edit'
      end
    end

    def destroy
      raise ActionController::RoutingError.new('Not Found') unless @policy.can_destroy?(@script)

      @script.destroy
      redirect_to scripts_path
    end

    def execute
      raise ActionController::RoutingError.new('Not Found') unless @policy.can_execute?(@script)

      @script.update(executor_id: current_user.id)
      ScriptExecutorJob.perform_later(@script.id)

      redirect_to script_path(@script)
    end

    private

    def set_script
      @script = Script.find(params[:id])
    end

    def set_policy
      @policy = ScriptPolicy.new(user: current_user)
    end

    def permitted_params
      tags = process_tags(params.dig('script', 'tags'))
      params.require(:script).permit(:title, :description, :code, :ticket_url).merge(tags: tags)
    end

    def process_filters
      tags = process_tags(params.dig(:q, :tags_contains_array))
      params[:q][:tags_contains_array] = tags if tags.present?
    end

    def process_tags(tags_params)
      raw_tags = JSON.parse(tags_params) if tags_params.present?
      raw_tags.to_a.map { |raw_tag| raw_tag['value'] }
    end

    def load_filter_options
      @creators = User.where(id: CatarseScripts::Script.pluck(:creator_id).uniq)
      @statuses = CatarseScripts::Script.statuses.transform_keys { |k| k.humanize }.to_a
    end

    def load_tags
      @tags = CatarseScripts::Script.pluck(:tags).flatten.uniq.join(', ')
    end
  end
end
