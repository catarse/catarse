# frozen_string_literal: true

class UserLink < ActiveRecord::Base
  include I18n::Alchemy
  before_save :prepend_protocol
  belongs_to :user
  scope :with_link, -> { where('link IS NOT NULL') }

  def without_protocol
    link.sub(/^https?\:\/\//, '').sub(/^www./, '')
  end

  def hostname
    without_protocol.split('/')[0]
  end

  def prepend_protocol
    self.link = ('http://' + link) unless link[/^https?:\/\//]
  end
end
