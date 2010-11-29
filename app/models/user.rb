class User < ActiveRecord::Base
  validates_presence_of :provider, :uid
  validates_uniqueness_of :uid, :scope => :provider
  validates_format_of :email, :with => /^[A-Z0-9_\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,4}|museum|travel)$/i
end
