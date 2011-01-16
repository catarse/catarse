class User < ActiveRecord::Base
  validates_presence_of :provider, :uid
  validates_uniqueness_of :uid, :scope => :provider
  validates_length_of :bio, :maximum => 140
  validates :email, :email => true, :allow_nil => true, :allow_blank => true
  has_many :backs, :class_name => "Backer"
  has_many :projects
  has_many :secondary_users, :class_name => 'User', :foreign_key => :primary_user_id
  belongs_to :primary, :class_name => 'User', :foreign_key => :primary_user_id

  scope :primary, :conditions => ["primary_user_id IS NULL"]
  before_save :store_primary_user

  def store_primary_user
    return if email.nil? or self.primary_user_id
    primary_user = User.primary.where(:email => email).first
    if primary_user and primary_user.id != self.id
      self.primary_user_id = primary_user.id
    end
  end

  def to_param
    return "#{self.id}" unless self.name
    "#{self.id}-#{self.name.parameterize}"
  end

  def self.find_with_omni_auth(provider, uid)
    u = User.find_by_provider_and_uid(provider, uid)
    return nil unless u
    u.primary.nil? ? u : u.primary
  end

  def self.create_with_omniauth(auth, primary_user_id = nil)
    u = create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["user_info"]["name"]
      user.email = auth["user_info"]["email"] 
      user.email = auth["extra"]["user_hash"]["email"] if auth["extra"] and user.email.nil?
      user.nickname = auth["user_info"]["nickname"]
      user.bio = auth["user_info"]["description"][0..139] if auth["user_info"]["description"]
      user.image_url = auth["user_info"]["image"]
    end
    # If we could not associate by email we try to use the parameter
    if u.primary.nil? and primary_user_id
      u.primary = User.find_by_id(primary_user_id)
    end
    u.primary.nil? ? u : u.primary
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
    return unless email
    "http://gravatar.com/avatar/#{Digest::MD5.new.update(email)}.jpg?default=#{image_url or 'http://catarse.me/images/user.png'}"
  end
end
