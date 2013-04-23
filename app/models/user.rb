# coding: utf-8

# uid and provider are deprecated we need to use this data from authorizations ALWAYS!

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :omniauthable
  begin
    # NOTE: Sync normal users on mailchimp
    sync_with_mailchimp subscribe_data: ->(user) {
                          { EMAIL: user.email, FNAME: user.name,
                          CITY: user.address_city, STATE: user.address_state }
                        },
                        list_id: Configuration[:mailchimp_list_id],
                        subscribe_when: ->(user) { user.newsletter_changed? && user.newsletter },
                        unsubscribe_when: ->(user) { user.newsletter_changed? && !user.newsletter },
                        unsubscribe_email: ->(user) { user.email }

  rescue Exception => e
    Airbrake.notify({ :error_class => "MailChimp Error", :error_message => "MailChimp Error: #{e.inspect}", :parameters => params}) rescue nil
    Rails.logger.info "-----> #{e.inspect}"
  end

  delegate  :display_name, :display_image, :short_name, :display_provider, :display_image_html,
    :medium_name, :display_credits, :display_total_of_backs,
    :to => :decorator

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

  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include Rails.application.routes.url_helpers

  mount_uploader :uploaded_image, LogoUploader

  validates_length_of :bio, :maximum => 140
  validates :email, email: true, uniqueness: true, allow_nil: true, allow_blank: true
  #validates :name, :presence => true, :if => :is_devise?

  validates_presence_of     :email, :if => :is_devise?
  validates_uniqueness_of   :email, :scope => :provider, :if => :is_devise?
  validates_presence_of     :password, :if => :password_required?
  validates_confirmation_of :password, :if => :password_confirmation_required?
  validates_length_of       :password, :within => 6..128, :allow_blank => true

  schema_associations
  has_many :oauth_providers, through: :authorizations
  has_many :backs, class_name: "Backer"
  has_one :user_total


  # Channels relation
  has_and_belongs_to_many :channels, join_table: :channels_trustees
  has_and_belongs_to_many :subscriptions, join_table: :channels_subscribers, class_name: 'Channel'
  has_many :channels_projects, through: :channels, source: :projects
  has_many :channels_subscribers



  accepts_nested_attributes_for :unsubscribes, allow_destroy: true rescue puts "No association found for name 'unsubscribes'. Has it been defined yet?"
  scope :backers, :conditions => ["id IN (SELECT DISTINCT user_id FROM backers WHERE confirmed)"]
  scope :who_backed_project, ->(project_id){ where("id IN (SELECT user_id FROM backers WHERE confirmed AND project_id = ?)", project_id) }
  scope :subscribed_to_updates, where("id NOT IN (SELECT user_id FROM unsubscribes WHERE project_id IS NULL AND notification_type_id = (SELECT id from notification_types WHERE name = 'updates'))")
  scope :subscribed_to_project, ->(project_id){ who_backed_project(project_id).where("id NOT IN (SELECT user_id FROM unsubscribes WHERE project_id = ?)", project_id) }
  scope :by_email, ->(email){ where('email ~* ?', email) }
  scope :by_payer_email, ->(email){  where('EXISTS(SELECT true FROM backers JOIN payment_notifications ON backers.id = payment_notifications.backer_id WHERE backers.user_id = users.id AND payment_notifications.extra_data ~* ?)', email) }
  scope :by_name, ->(name){ where('name ~* ?', name) }
  scope :by_id, ->(id){ where('users.id = ?', id) }
  scope :by_key, ->(key){ where('EXISTS(SELECT true FROM backers WHERE backers.user_id = users.id AND backers.key ~* ?)', key) }
  scope :has_credits, joins(:user_total).where('user_totals.credits > 0')
  scope :order_by, ->(sort_field){ order(sort_field) }

  def self.backer_totals
    connection.select_one(
      self.scoped.
      joins(:user_total).
      select('count(DISTINCT user_id) as users, count(*) as backers, sum(user_totals.sum) as backed, sum(user_totals.credits) as credits').
      to_sql
    ).reduce({}){|memo,el| memo.merge({ el[0].to_sym => BigDecimal.new(el[1] || '0') }) }
  end
  
  def has_facebook_authentication?
    oauth = OauthProvider.find_by_name 'facebook'
    authorizations.where(oauth_provider_id: oauth.id).present?  
  end

  def decorator
    @decorator ||= UserDecorator.new(self)
  end

  def have_address?
    address_street.present? and address_number.present? and address_city.present?
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

  def facebook_id
    auth = authorizations.joins(:oauth_provider).where("oauth_providers.name = 'facebook'").first
    auth.uid if auth
  end

  def to_param
    return "#{self.id}" unless self.display_name
    "#{self.id}-#{self.display_name.parameterize}"
  end

  def self.create_with_omniauth(auth, current_user = nil)
    if current_user
      u = current_user
    else
      u = create! do |user|
        user.name = auth["info"]["name"]
        user.email = (auth["info"]["email"] rescue nil)
        user.email = (auth["extra"]["user_hash"]["email"] rescue nil) unless user.email
        user.nickname = auth["info"]["nickname"]
        user.bio = (auth["info"]["description"][0..139] rescue nil)
        user.locale = I18n.locale.to_s
        user.image_url = "https://graph.facebook.com/#{auth['uid']}/picture?type=large" if auth["provider"] == "facebook"
      end    
    end
    provider = OauthProvider.where(name: auth['provider']).first
    u.authorizations.create! uid: auth['uid'], oauth_provider_id: provider.id if provider
    u
  end

  def recommended_project
    # It returns the project that have the biggest amount of backers
    # that contributed to the last project the user contributed that has common backers.
    backs.includes(:project).confirmed.order('confirmed_at DESC').each do |back|
      project = ActiveRecord::Base.connection.execute("SELECT count(*), project_id FROM backers b JOIN projects p ON b.project_id = p.id WHERE p.expires_at > current_timestamp AND p.id NOT IN (SELECT project_id FROM backers WHERE confirmed AND user_id = #{id}) AND b.user_id in (SELECT user_id FROM backers WHERE confirmed AND project_id = #{back.project.id.to_i}) AND p.state = 'online' GROUP BY 2 ORDER BY 1 DESC LIMIT 1")
      return Project.find(project[0]["project_id"]) unless project.count == 0
    end
    nil
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

  def as_json(options={})

    json_attributes = {}

    if not options or (options and not options[:anonymous])
      json_attributes.merge!({
        :id => id,
        :name => display_name,
        :short_name => short_name,
        :medium_name => medium_name,
        :image => display_image,
        :total_backs => total_backs,
        :backs_text => backs_text,
        :url => user_path(self),
        :city => address_city,
        :state => address_state
      })
    end

    if options and options[:can_manage]
      json_attributes.merge!({
        :email => email
      })
    end

    json_attributes

  end

  def is_devise?
    provider == 'devise'
  end

  def twitter_link
    "http://twitter.com/#{self.twitter}"
  end

  def fix_twitter_user
    self.twitter.gsub!(/@/, '') if self.twitter
  end

  # Returns a Gravatar URL associated with the email parameter, uses local avatar if available
  def gravatar_url
    return unless email
    "https://gravatar.com/avatar/#{Digest::MD5.new.update(email)}.jpg?default=#{::Configuration[:base_url]}/assets/user.png"
  end

  protected
  def password_confirmation_required?
    !password.nil?
  end

  def password_required?
    is_devise? && (!persisted? || !password.nil? || !password_confirmation.nil?)
  end
end
