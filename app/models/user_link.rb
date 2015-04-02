class UserLink < ActiveRecord::Base
  before_save :fix_link
  belongs_to :user

  def link_without_protocol
    self.link.sub(/^https?\:\/\//, '').sub(/^www./,'')
  end

  def fix_link
    self.link = ('http://' + self.link) unless self.link[/^https?:\/\//]
  end

end
