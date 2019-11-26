class SetNotDraftProjectsToNoAdultContent < ActiveRecord::Migration
  def up
    Project.where.not(state:'draft').update_all(content_rating: 0)
  end

  def down
    Project.where.not(state:'draft').update_all(content_rating: nil)
  end
end
