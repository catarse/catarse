class Category < ActiveRecord::Base
  has_notifications
  has_many :projects
  has_many :category_followers
  has_many :users, through: :category_followers

  delegate :display_name, to: :decorator


  validates_presence_of :name_pt
  validates_uniqueness_of :name_pt

  scope :with_projects_on_this_week, -> {
    joins(:projects).merge(Project.with_state('online').of_current_week).uniq
  }

  def self.with_projects
    where("exists(select true from projects p where p.category_id = categories.id and p.state not in('draft', 'rejected'))")
  end

  def self.array
    order('name_'+ I18n.locale.to_s + ' ASC').collect { |c| [c.send('name_' + I18n.locale.to_s), c.id] }
  end

  def to_s
    self.send('name_' + I18n.locale.to_s)
  end

  def deliver_projects_of_week_notification
    self.users.to_send_category_notification(self.id).each do |user|
      self.notify(:categorized_projects_of_the_week, user, self)
    end
  end

  def decorator
    @decorator ||= CategoryDecorator.new(self)
  end

end
