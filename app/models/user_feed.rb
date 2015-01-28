class UserFeed < ActiveRecord::Base
  self.primary_key = :user_id

  scope :ordered, -> { order(event_date: :desc) }

  def is_project_post?
    self.event_type == 'project_posts'
  end

  def is_category_follower_project?
    self.event_type == 'new_project_on_category'
  end

  def is_finished_project?
    self.event_type == 'contributed_project_finished'
  end

  def is_common_owner?
    self.event_type == 'new_project_from_common_owner'
  end

  def from_object
    if from_type.present?
      kclass = from_type.constantize
      kclass.find(from_id)
    end
  end

  def to_object
    if to_type.present?
      kclass = to_type.constantize
      kclass.find(to_id)
    end
  end
end
