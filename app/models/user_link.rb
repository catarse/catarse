class UserLink < ActiveRecord::Base
  before_save :fix_link
  belongs_to :user
  scope :with_link, ->{ where('link IS NOT NULL') }

  def without_protocol
    self.link.sub(/^https?\:\/\//, '').sub(/^www./,'')
  end

  def fix_link
    self.link = ('http://' + self.link) unless self.link[/^https?:\/\//]
  end

end
