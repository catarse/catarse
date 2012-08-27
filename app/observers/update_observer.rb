class UpdateObserver < ActiveRecord::Observer
  observe :update

  def after_create(update)
    update.notify_backers
  end
end
