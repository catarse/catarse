# coding: utf-8


class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  # :validatable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :omniauthable
  begin
    # NOTE: Sync normal users on mailchimp
    sync_with_mailchimp subscribe_data: ->(user) {
                          { EMAIL: user.email, FNAME: user.name,
                          CITY: (user.address_city||'outro / other'), STATE: (user.address_state||'outro / other') }
                        },
                        list_id: Configuration[:mailchimp_list_id],
                        subscribe_when: ->(user) { user.newsletter_changed? && user.newsletter },
                        unsubscribe_when: ->(user) { user.newsletter_changed? && !user.newsletter },
                        unsubscribe_email: ->(user) { user.email }

  rescue Exception => e
    Rails.logger.info "-----> #{e.inspect}"
  end

  delegate  :display_name, :display_image, :short_name, :display_image_html,
    :medium_name, :display_credits, :display_total_of_backs,
    to: :decorator
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email,
    :password,
    :password_confirmation,
    :remember_me,
    :name,
    :nickname,
    :image_url,
    :uploaded_image,
    :bio,
    :newsletter,
    :full_name,
    :address_street,
    :address_number,
    :address_complement,
    :address_neighbourhood,
    :address_city,
    :address_state,
    :address_zip_code,
    :phone_number,
    :cpf,
    :state_inscription,
    :locale,
    :twitter,
    :facebook_link,
    :other_link,
    :moip_login

  mount_uploader :uploaded_image, UserUploader

  validates_length_of :bio, maximum: 140

  validates_presence_of :email
  validates_uniqueness_of :email, :allow_blank => true, :if => :email_changed?, :message => I18n.t('activerecord.errors.models.user.attributes.email.taken')
  validates_format_of :email, :with => Devise.email_regexp, :allow_blank => true, :if => :email_changed?

  validates_presence_of :password, :if => :password_required?
  validates_confirmation_of :password, :if => :password_confirmation_required?
  validates_length_of :password, :within => Devise.password_length, :allow_blank => true

  schema_associations
  has_many :oauth_providers, through: :authorizations
  has_many :backs, class_name: "Backer"
  has_one :user_total
  has_and_belongs_to_many :recommended_projects, join_table: :recommendations, class_name: 'Project'


  # Channels relation
  has_and_belongs_to_many :channels, join_table: :channels_trustees
  has_and_belongs_to_many :subscriptions, join_table: :channels_subscribers, class_name: 'Channel'
  has_many :channels_projects, through: :channels, source: :projects
  has_many :channels_subscribers

  accepts_nested_attributes_for :unsubscribes, allow_destroy: true rescue puts "No association found for name 'unsubscribes'. Has it been defined yet?"

  scope :backers, -> {
    where("id IN (
      SELECT DISTINCT user_id
      FROM backers
      WHERE backers.state <> ALL(ARRAY['pending'::character varying::text, 'canceled'::character varying::text]))")
  }

  scope :who_backed_project, ->(project_id) {
    where("id IN (SELECT user_id FROM backers WHERE backers.state = 'confirmed' AND project_id = ?)", project_id)
  }

  scope :subscribed_to_updates, -> {
     where("id NOT IN (
       SELECT user_id
       FROM unsubscribes
       WHERE project_id IS NULL
       AND notification_type_id = (SELECT id from notification_types WHERE name = 'updates'))")
   }

  scope :subscribed_to_project, ->(project_id) {
    who_backed_project(project_id).
    where("id NOT IN (SELECT user_id FROM unsubscribes WHERE project_id = ?)", project_id)
  }

  scope :by_email, ->(email){ where('email ~* ?', email) }
  scope :by_payer_email, ->(email) {
    where('EXISTS(
      SELECT true
      FROM backers
      JOIN payment_notifications ON backers.id = payment_notifications.backer_id
      WHERE backers.user_id = users.id AND payment_notifications.extra_data ~* ?)', email)
  }
  scope :by_name, ->(name){ where('users.name ~* ?', name) }
  scope :by_id, ->(id){ where(id: id) }
  scope :by_key, ->(key){ where('EXISTS(SELECT true FROM backers WHERE backers.user_id = users.id AND backers.key ~* ?)', key) }
  scope :has_credits, joins(:user_total).where('user_totals.credits > 0')
  scope :order_by, ->(sort_field){ order(sort_field) }

  def self.backer_totals
    connection.select_one(
      self.scoped.
      joins(:user_total).
      select('
        count(DISTINCT user_id) as users,
        count(*) as backers,
        sum(user_totals.sum) as backed,
        sum(user_totals.credits) as credits').
      to_sql
    ).reduce({}){|memo,el| memo.merge({ el[0].to_sym => BigDecimal.new(el[1] || '0') }) }
  end

  def has_facebook_authentication?
    oauth = OauthProvider.find_by_name 'facebook'
    authorizations.where(oauth_provider_id: oauth.id).present? if oauth
  end

  def decorator
    @decorator ||= UserDecorator.new(self)
  end

  def admin?
    admin
  end

  # NOTE: Checking if the user has CHANNELS
  # If the user has some channels, this method returns TRUE
  # Otherwise, it's FALSE
  def trustee?
    !self.channels.size.zero?
  end

  def credits
    user_total ? user_total.credits : 0.0
  end

  def total_backed_projects
    user_total ? user_total.total_backed_projects : 0
  end

  def facebook_id
    auth = authorizations.joins(:oauth_provider).where("oauth_providers.name = 'facebook'").first
    auth.uid if auth
  end

  def to_param
    return "#{self.id}" unless self.display_name
    "#{self.id}-#{self.display_name.parameterize}"
  end

  def self.create_with_omniauth(auth, current_user = nil)
    omniauth_email = (auth["info"]["email"] rescue nil)
    omniauth_email = (auth["extra"]["user_hash"]["email"] rescue nil) unless omniauth_email
    if current_user
      u = current_user
    elsif omniauth_email && u = User.find_by_email(omniauth_email)
    else
      u = new do |user|
        user.name = auth["info"]["name"]
        user.email = omniauth_email
        user.nickname = auth["info"]["nickname"]
        user.bio = (auth["info"]["description"][0..139] rescue nil)
        user.locale = I18n.locale.to_s
        user.image_url = "https://graph.facebook.com/#{auth['uid']}/picture?type=large" if auth["provider"] == "facebook"
      end
    end
    provider = OauthProvider.where(name: auth['provider']).first
    u.authorizations.build(uid: auth['uid'], oauth_provider_id: provider.id) if provider
    u.save!
    u
  end

  def total_backs
    backs.confirmed.not_anonymous.count
  end

  def updates_subscription
    unsubscribes.updates_unsubscribe(nil)
  end

  def project_unsubscribes
    backed_projects.map do |p|
      unsubscribes.updates_unsubscribe(p.id)
    end
  end

  def backed_projects
    Project.backed_by(self.id)
  end

  def backs_text
    if total_backed_projects == 2
      I18n.t('user.backs_text.two')
    elsif total_backed_projects > 1
      I18n.t('user.backs_text.many', total: (total_backed_projects-1))
    else
      I18n.t('user.backs_text.one')
    end
  end

  def twitter_link
    "http://twitter.com/#{self.twitter}"
  end

  def fix_twitter_user
    self.twitter.gsub!(/@/, '') if self.twitter
  end

  def fix_facebook_link
    if !self.facebook_link.blank?
      self.facebook_link = ('http://' + self.facebook_link) unless self.facebook_link[/^https?:\/\//]
    end
  end

  # Returns a Gravatar URL associated with the email parameter, uses local avatar if available
  def gravatar_url
    return unless email
    "https://gravatar.com/avatar/#{Digest::MD5.new.update(email)}.jpg?default=#{::Configuration[:base_url]}/assets/user.png"
  end

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def password_confirmation_required?
    !new_record?
  end

end
