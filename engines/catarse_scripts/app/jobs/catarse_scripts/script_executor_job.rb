module CatarseScripts
  class ScriptExecutorJob < ApplicationJob
    include Sidekiq::Status::Worker

    self.queue_adapter = :sidekiq
    queue_as :default

    def perform(script_id)
      script = Script.find(script_id)
      script.update(status: :running)
      eval(script.code)
      script_class = script.class_name.constantize
      script_class.new.call(self)
      script.update(status: :done)
    rescue => e
      script.update(status: :with_error)
      Raven.extra_context(
        script_id: script.id,
        script_title: script.title,
        script_class_name: script.class_name
      )
      Raven.capture_exception(e)
    end
  end
end
