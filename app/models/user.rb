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
                        subscribe_when: ->(user) { (user.newsletter_changed? && user.newsletter) || (user.newsletter && user.new_record?) },
                        unsubscribe_when: ->(user) { user.newsletter_changed? && !user.newsletter },
                        unsubscribe_email: ->(user) { user.email }

  rescue Exception => e
    Rails.logger.info "-----> #{e.inspect}"
  end

  delegate  :display_name, :display_image, :short_name, :display_image_html,
    :medium_name, :display_credits, :display_total_of_contributions, :contributions_text, :twitter_link, :gravatar_url,
    to: :decorator

  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :nickname,
    :image_url, :uploaded_image, :bio, :newsletter, :full_name, :address_street, :address_number,
    :address_complement, :address_neighbourhood, :address_city, :address_state, :address_zip_code, :phone_number,
    :cpf, :state_inscription, :locale, :twitter, :facebook_link, :other_link, :moip_login

  mount_uploader :uploaded_image, UserUploader

  validates_length_of :bio, maximum: 140

  validates_presence_of :email
  validates_uniqueness_of :email, allow_blank: true, if: :email_changed?, message: I18n.t('activerecord.errors.models.user.attributes.email.taken')
  validates_format_of :email, with: Devise.email_regexp, allow_blank: true, if: :email_changed?

  validates_presence_of :password, if: :password_required?
  validates_confirmation_of :password, if: :password_confirmation_required?
  validates_length_of :password, within: Devise.password_length, allow_blank: true

  schema_associations
  has_many :oauth_providers, through: :authorizations
  has_one :user_total
  has_and_belongs_to_many :recommended_projects, join_table: :recommendations, class_name: 'Project'


  # Channels relation
  has_and_belongs_to_many :subscriptions, join_table: :channels_subscribers, class_name: 'Channel'

  accepts_nested_attributes_for :unsubscribes, allow_destroy: true rescue puts "No association found for name 'unsubscribes'. Has it been defined yet?"

  scope :contributions, -> {
    where("id IN (
      SELECT DISTINCT user_id
      FROM contributions
      WHERE contributions.state <> ALL(ARRAY['pending'::character varying::text, 'canceled'::character varying::text]))")
  }

  scope :who_contributed_project, ->(project_id) {
    where("id IN (SELECT user_id FROM contributions WHERE contributions.state = 'confirmed' AND project_id = ?)", project_id)
  }

  scope :subscribed_to_updates, -> {
     where("id NOT IN (
       SELECT user_id
       FROM unsubscribes
       WHERE project_id IS NULL)")
   }

  scope :subscribed_to_project, ->(project_id) {
    who_contributed_project(project_id).
    where("id NOT IN (SELECT user_id FROM unsubscribes WHERE project_id = ?)", project_id)
  }

  scope :by_email, ->(email){ where('email ~* ?', email) }
  scope :by_payer_email, ->(email) {
    where('EXISTS(
      SELECT true
      FROM contributions
      JOIN payment_notifications ON contributions.id = payment_notifications.contribution_id
      WHERE contributions.user_id = users.id AND payment_notifications.extra_data ~* ?)', email)
  }
  scope :by_name, ->(name){ where('users.name ~* ?', name) }
  scope :by_id, ->(id){ where(id: id) }
  scope :by_key, ->(key){ where('EXISTS(SELECT true FROM contributions WHERE contributions.user_id = users.id AND contributions.key ~* ?)', key) }
  scope :has_credits, -> { joins(:user_total).where('user_totals.credits > 0') }
  scope :has_not_used_credits_last_month, -> { has_credits.
    where("NOT EXISTS (SELECT true FROM contributions b WHERE current_timestamp - b.created_at < '1 month'::interval AND b.credits AND b.state = 'confirmed' AND b.user_id = users.id)")
  }
  scope :order_by, ->(sort_field){ order(sort_field) }

  def self.send_credits_notification
    has_not_used_credits_last_month.find_each do |user|
      Notification.notify_once(
        :credits_warning,
        user,
        {user_id: user.id}
      )
    end
  end

  def made_any_contribution_for_this_project?(project_id)
    contributions.available_to_count.where(project_id: project_id).present?
  end

  def has_facebook_authentication?
    oauth = OauthProvider.find_by_name 'facebook'
    authorizations.where(oauth_provider_id: oauth.id).present? if oauth
  end

  def decorator
    @decorator ||= UserDecorator.new(self)
  end

  def credits
    user_total.try(:credits).to_f
  end

  def total_contributed_projects
    user_total.try(:total_contributed_projects).to_i
  end

  def facebook_id
    auth = authorizations.joins(:oauth_provider).where("oauth_providers.name = 'facebook'").first
    auth.uid if auth
  end

  def to_param
    return "#{self.id}" unless self.display_name
    "#{self.id}-#{self.display_name.parameterize}"
  end

  def self.create_from_hash(hash)
    create!(
      {
        name: hash['info']['name'],
        email: hash['info']['email'],
        nickname: hash["info"]["nickname"],
        bio: (hash["info"]["description"][0..139] rescue nil),
        locale: I18n.locale.to_s,
        image_url: "https://graph.facebook.com/#{hash['uid']}/picture?type=large"
      }
    )
  end

  def total_contributions
    contributions.confirmed.not_anonymous.count
  end

  def updates_subscription
    unsubscribes.updates_unsubscribe(nil)
  end

  def project_unsubscribes
    contributed_projects.map do |p|
      unsubscribes.updates_unsubscribe(p.id)
    end
  end

  def contributed_projects
    Project.contributed_by(self.id)
  end

  def fix_twitter_user
    self.twitter.gsub!(/@/, '') if self.twitter
  end

  def fix_facebook_link
    if !self.facebook_link.blank?
      self.facebook_link = ('http://' + self.facebook_link) unless self.facebook_link[/^https?:\/\//]
    end
  end

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def password_confirmation_required?
    !new_record?
  end

end
