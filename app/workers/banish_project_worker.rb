# frozen_string_literal: true

class BanishProjectWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform(project_id)
    BanishProjectAction.new(project_id: project_id).call()
  end
end
