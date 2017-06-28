# frozen_string_literal: true

class Notification < ActiveRecord::Base
  belongs_to :user

  def self.notify_once(template_name, user, params = {})
    # notify(template_name, user, source, params) if is_unique?(template_name, {self.user_association_name => user})
  end

  def self.notify(template_name, user, params = {})
    create!({
              template_name: template_name,
              user: (user.is_a?(User) ? user : nil),
              user_email: (user.is_a?(User) ? user.email : user),
              metadata: {
                locale: I18n.locale,
                from_email: UserNotifier.from_email,
                from_name: UserNotifier.from_name
              }.merge(params)
            })
  end

  def deliver
    deliver! unless sent_at.present?
  end

  def deliver!
    EmailWorker.perform_at((try(:deliver_at) || Time.now), id)
  end

  def deliver_without_worker
    mailer.notify(self).deliver
  end

  def mailer
    Notifier
  end

  def from_name
    @from_name ||= metadata.try(:[], 'from_name')
  end

  def from_email
    @from_email ||= metadata.try(:[], 'from_email')
  end

  def locale
    @locale ||= (metadata.try(:[], 'locale') || 'pt')
  end

  def project
    project_id = metadata_associations.try(:[], 'project_id')
    @project ||= Project.find(project_id) if project_id
  end

  def contribution
    contribution_id = metadata_associations.try(:[], 'contribution_id')
    @contribution ||= Contribution.find(contribution_id) if contribution_id
  end

  def balance_transfer
    balance_transfer_id = metadata_associations.try(:[], 'balance_transfer_id')
    @balance_transfer ||= BalanceTransfer.find balance_transfer_id
  end

  private

  def metadata_associations
    @metadata_associations ||= metadata.try(:[], 'associations')
  end

  def self.is_unique?(template_name, filter)
    filter.nil? || where(filter.merge(template_name: template_name)).empty?
  end
end
