# coding: utf-8
class User < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include Rails.application.routes.url_helpers

  begin
    sync_with_mailee :news => :newsletter, :list => "Newsletter"
  rescue Exception => e
    Rails.logger.error "Error when syncing with mailee: #{e.inspect}"
  end

  validates_presence_of :provider, :uid
  validates_uniqueness_of :uid, :scope => :provider
  validates_length_of :bio, :maximum => 140
  validates :email, :email => true, :allow_nil => true, :allow_blank => true
  has_many :backs, :class_name => "Backer"
  has_many :projects
  has_many :notifications
  has_many :secondary_users, :class_name => 'User', :foreign_key => :primary_user_id
  has_and_belongs_to_many :manages_projects, :join_table => "projects_managers", :class_name => 'Project'
  belongs_to :primary, :class_name => 'User', :foreign_key => :primary_user_id
  scope :primary, :conditions => ["primary_user_id IS NULL"]
  scope :backers, :conditions => ["id IN (SELECT DISTINCT user_id FROM backers WHERE confirmed)"]
  #before_save :store_primary_user

  def admin?
    admin
  end

  def calculate_credits(sum = 0, backs = [], first = true)
   # return sum if backs.size == 0 and not first
   backs = self.backs.where(:confirmed => true, :requested_refund => false).order("created_at").all if backs == [] and first
   back = backs.first
   return sum unless back
   sum -= back.value if back.credits
   if back.project.finished?
     unless back.project.successful?
       sum += back.value
       # puts "#{back.project.name}: +#{back.value}"
     end
   end
   calculate_credits(sum, backs.drop(1), false)
  end

  def update_credits
    self.update_attribute :credits, self.calculate_credits
  end

  def store_primary_user
    return if email.nil? or self.primary_user_id
    primary_user = User.primary.where(:email => email).first
    if primary_user and primary_user.id != self.id
      self.primary_user_id = primary_user.id
    end
  end

  def to_param
    return "#{self.id}" unless self.display_name
    "#{self.id}-#{self.display_name.parameterize}"
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
      user.name = auth["user_info"][:name] if user.name.nil?
      user.email = auth["user_info"]["email"]
      user.email = auth["extra"]["user_hash"]["email"] if auth["extra"] and auth["extra"]["user_hash"] and user.email.nil?
      user.nickname = auth["user_info"]["nickname"]
      user.bio = auth["user_info"]["description"][0..139] if auth["user_info"]["description"]
      user.image_url = auth["user_info"]["image"]
      user.locale = I18n.locale.to_s
    end
    # If we could not associate by email we try to use the parameter
    if u.primary.nil? and primary_user_id
      u.primary = User.find_by_id(primary_user_id)
    end
    u.primary.nil? ? u : u.primary
  end
  def display_name
    name || nickname || I18n.t('user.no_name')
  end
  def display_nickname
    if nickname =~ /profile\.php/
      name
    else
      nickname||name
    end
  end
  def short_name
    truncate display_name, :length => 26
  end
  def medium_name
    truncate display_name, :length => 42
  end
  def display_image
    gravatar_url || image_url || '/images/user.png'
  end
  def backer?
    backs.confirmed.not_anonymous.count > 0
  end
  def total_backs
    backs.confirmed.not_anonymous.count
  end
  def backs_text
    if total_backs == 2
      I18n.t('user.backs_text.two')
    elsif total_backs > 1
      I18n.t('user.backs_text.many', :total => (total_backs-1))
    else
      I18n.t('user.backs_text.one')
    end
  end
  def remember_me_hash
    Digest::MD5.new.update("#{self.provider}###{self.uid}").to_s
  end
  def display_credits
    number_to_currency credits, :unit => 'R$', :precision => 0, :delimiter => '.'
  end
  def merge_into!(new_user)
    self.primary = new_user
    new_user.credits += self.credits
    self.credits = 0
    self.backs.update_all :user_id => new_user.id
    self.projects.update_all :user_id => new_user.id
    self.notifications.update_all :user_id => new_user.id
    self.save
    new_user.save
  end

  def as_json(options={})

    json_attributes = {}
    
    if options and not options[:anonymous] 
      json_attributes.merge!({
        :id => id,
        :name => display_name,
        :short_name => short_name,
        :medium_name => medium_name,
        :image => display_image,
        :total_backs => total_backs,
        :backs_text => backs_text,
        :url => user_path(self)
      })
    end

    if options and options[:can_manage]
      json_attributes.merge!({
        :email => email
      })
    end
    
    json_attributes

  end

  protected

  # Returns a Gravatar URL associated with the email parameter
  def gravatar_url
    return unless email
    "http://gravatar.com/avatar/#{Digest::MD5.new.update(email)}.jpg?default=#{image_url or "#{I18n.t('site.base_url')}/images/user.png"}"
  end
end
