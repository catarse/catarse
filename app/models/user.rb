class User < ActiveRecord::Base
  validates_presence_of :provider, :uid
  validates_uniqueness_of :uid, :scope => :provider
  validates_length_of :bio, :maximum => 140
  validates :email, :email => true, :allow_nil => true, :allow_blank => true
  has_many :backs, :class_name => "Backer"

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["user_info"]["name"]
      user.email = auth["user_info"]["email"] 
      user.email = auth["extra"]["user_hash"]["email"] if auth["extra"] and user.email.nil?
      user.nickname = auth["user_info"]["nickname"]
      user.bio = auth["user_info"]["description"][0..139] if auth["user_info"]["description"]
      user.image_url = auth["user_info"]["image"]
    end
  end
  def display_name
    name || nickname || "Sem nome"
  end
  def display_image
    gravatar_url || image_url || 'user.png'
  end
  def backer?
    backs.confirmed.count > 0
  end

  protected

  # Returns a Gravatar URL associated with the email parameter
  def gravatar_url
    email.nil? ? nil : "http://gravatar.com/avatar/#{Digest::MD5.new.update(email)}.jpg?default=http://catarse.heroku.com/images/user.png"
  end
end
