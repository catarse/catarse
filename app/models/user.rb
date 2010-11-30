class User < ActiveRecord::Base
  validates_presence_of :provider, :uid
  validates_uniqueness_of :uid, :scope => :provider
  #validates_format_of :email, :with => /^[A-Z0-9_\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,4}|museum|travel)$/i

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["user_info"]["name"]
      user.nickname = auth["user_info"]["nickname"]
      user.biography = auth["user_info"]["description"]
      user.image_url = auth["user_info"]["image"]
    end  
  end
  
  def display_name
    name || nickname || "Sem nome"
  end
  def display_image
    image_url || 'user.png'
  end
end
