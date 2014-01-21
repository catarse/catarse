class UpdateObserver < ActiveRecord::Observer
  observe :update

  def after_create(update)
    update.notify_contributors
  end
end
