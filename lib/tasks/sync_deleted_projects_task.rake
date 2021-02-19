# frozen_string_literal: true

class SyncDeletedProjectsTask
  include Rake::DSL

  def initialize
    namespace :projects do
      task sync_deleted_projects: :environment do
        call
      end
    end
  end

  private

  def call
    ProjectTransition
    .where("created_at > now() - '24 hours'::interval AND to_state = 'deleted'")
    .pluck(:project_id).each do |pr|
      p = Project.find pr
      p.index_on_common
    end
  end
end

SyncDeletedProjectsTask.new
