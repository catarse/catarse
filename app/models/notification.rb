class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :channel
  belongs_to :channel_post
  belongs_to :contribution
  belongs_to :project_post

  validates_presence_of :user

  scope :last_with_template, ->(template_name){
    where(template_name: template_name).order(:id).last
  }

  def self.notify_once(template_name, user, filter, params = {})
    notify(template_name, user, params) if is_unique?(template_name, filter)
  end

  def self.notify(template_name, user, params = {})
    create!({
      template_name: template_name,
      user: user,
      locale: user.locale || I18n.locale,
      origin_email: CatarseSettings[:email_contact],
      origin_name: CatarseSettings[:company_name]
    }.merge(params)).deliver
  end

  def deliver
    unless dismissed
      NotificationWorker.perform_async(self.id)
    end
  end

  private
  def self.is_unique?(template_name, filter)
    filter.nil? || self.where(filter.merge(template_name: template_name)).empty?
  end
end
