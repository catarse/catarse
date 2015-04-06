# coding: utf-8
class User < ActiveRecord::Base
  include User::OmniauthHandler
  has_notifications
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  # :validatable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :omniauthable

  delegate  :display_name, :display_image, :short_name, :display_image_html,
    :medium_name, :display_credits, :display_total_of_contributions, :contributions_text,
    :twitter_link, :display_bank_account, :display_bank_account_owner, to: :decorator

  # FIXME: Please bitch...
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :permalink,
    :image_url, :uploaded_image, :newsletter, :address_street, :address_number,
    :address_complement, :address_neighbourhood, :address_city, :address_state, :address_zip_code, :phone_number,
    :cpf, :state_inscription, :locale, :twitter, :facebook_link, :other_link, :moip_login, :deactivated_at, :reactivate_token,
    :bank_account_attributes, :country_id, :zero_credits, :links_attributes, :about_html, :cover_image, :category_followers_attributes, :category_follower_ids,
    :subscribed_to_project_posts

  mount_uploader :uploaded_image, UserUploader
  mount_uploader :cover_image, CoverUploader


  validates_presence_of :email
  validates_uniqueness_of :email, allow_blank: true, if: :email_changed?, message: I18n.t('activerecord.errors.models.user.attributes.email.taken')
  validates_uniqueness_of :permalink, allow_nil: true
  validates_format_of :email, with: Devise.email_regexp, allow_blank: true, if: :email_changed?

  validates_presence_of :password, if: :password_required?
  validates_confirmation_of :password, if: :password_confirmation_required?
  validates_length_of :password, within: Devise.password_length, allow_blank: true

  belongs_to :country
  has_one :user_total
  has_one :bank_account, dependent: :destroy
  has_many :feeds, class_name: 'UserFeed'
  has_many :credit_cards
  has_many :project_accounts
  has_many :authorizations
  has_many :contributions
  has_many :payments, through: :contributions
  has_many :projects, -> do
    without_state(:deleted)
  end
  has_many :published_projects, -> do
    with_states(Project::PUBLISHED_STATES)
  end, class_name: 'Project'
  has_many :unsubscribes
  has_many :project_posts
  has_many :contributed_projects, -> do
    distinct.where("contributions.was_confirmed").order('projects.created_at DESC')
  end, through: :contributions, source: :project
  has_many :category_followers, dependent: :destroy
  has_many :categories, through: :category_followers
  has_many :links, class_name: 'UserLink', inverse_of: :user
  has_and_belongs_to_many :recommended_projects, join_table: :recommendations, class_name: 'Project'

  accepts_nested_attributes_for :unsubscribes, allow_destroy: true rescue puts "No association found for name 'unsubscribes'. Has it been defined yet?"
  accepts_nested_attributes_for :links, allow_destroy: true, reject_if: ->(x) { x['link'].blank? }
  accepts_nested_attributes_for :bank_account, allow_destroy: true, reject_if: -> (attr) { attr[:bank_id].blank? }
  accepts_nested_attributes_for :category_followers, allow_destroy: true

  scope :with_permalink, -> { where("users.permalink is not null") }
  scope :active, ->{ where('deactivated_at IS NULL') }
  scope :with_user_totals, -> {
    joins("LEFT OUTER JOIN user_totals on user_totals.user_id = users.id")
  }

  scope :who_contributed_project, ->(project_id) {
    where("id IN (SELECT user_id FROM contributions WHERE contributions.was_confirmed AND project_id = ?)", project_id)
  }

  scope :subscribed_to_posts, -> {
     where("subscribed_to_project_posts")
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
  scope :by_key, ->(key){ where('EXISTS(
                                SELECT true 
                                FROM 
                                  contributions c 
                                  JOIN payments p ON c.id = p.contribution_id
                                WHERE c.user_id = users.id AND p.key = ?)', key
                               ) }
  scope :has_credits, -> { joins(:user_total).where('user_totals.credits > 0 and not users.zero_credits') }
  scope :already_used_credits, -> {
    has_credits.
    where("EXISTS (
            SELECT true 
            FROM 
              contributions c 
              JOIN payments p ON c.id = p.contribution_id 
            WHERE p.uses_credits AND p.state = 'paid' AND c.user_id = users.id)")
  }
  scope :has_not_used_credits_last_month, -> { has_credits.
    where("NOT EXISTS (
                SELECT true 
                FROM 
                  contributions c 
                  JOIN payments p ON c.id = p.contribution_id 
                WHERE 
                  current_timestamp - c.created_at < '1 month'::interval 
                  AND p.uses_credits AND p.state = 'paid' AND c.user_id = users.id)")
  }

  scope :to_send_category_notification, -> (category_id) {
    where("NOT EXISTS (
          select true from category_notifications n
          where n.template_name = 'categorized_projects_of_the_week' AND
          n.category_id = ? AND
          (n.created_at AT TIME ZONE '#{Time.zone.tzinfo.name}' + '7 days'::interval) >= current_timestamp AT TIME ZONE '#{Time.zone.tzinfo.name}' AND
          n.user_id = users.id)", category_id)
  }
  scope :order_by, ->(sort_field){ order(sort_field) }

  def self.find_active!(id)
    self.active.where(id: id).first!
  end

  def has_online_project?
    projects.with_state('online').exists?
  end

  def created_projects
    projects.with_state(['online', 'waiting_funds', 'successful', 'failed'])
  end

  def following_this_category?(category_id)
    category_followers.pluck(:category_id).include?(category_id)
  end

  def failed_contributed_projects
    contributed_projects.where(state: 'failed')
  end

  def send_credits_notification
    self.notify(:credits_warning)
  end

  def change_locale(language)
    if locale != language
      self.update_attributes locale: language
    end
  end

  def active_for_authentication?
    super && deactivated_at.nil?
  end

  def reactivate
    self.update_attributes deactivated_at: nil, reactivate_token: nil
  end

  def deactivate
    self.notify(:user_deactivate)
    self.update_attributes deactivated_at: Time.now, reactivate_token: Devise.friendly_token
    self.contributions.update_all(anonymous: true)
  end

  def made_any_contribution_for_this_project?(project_id)
    contributions.available_to_count.where(project_id: project_id).present?
  end

  def decorator
    @decorator ||= UserDecorator.new(self)
  end

  def credits
    return 0 if zero_credits
    user_total.try(:credits).to_f
  end

  def projects_in_reminder
    p = Array.new
    reminder_jobs = Sidekiq::ScheduledSet.new.select do |job|
      job['class'] == 'ReminderProjectWorker' && job.args[0] == self.id
    end
    reminder_jobs.each do |job|
      p << Project.find(job.args[1])
    end
    return p
  end

  def total_contributed_projects
    user_total.try(:total_contributed_projects).to_i
  end

  def has_no_confirmed_contribution_to_project(project_id)
    contributions.where(project_id: project_id).where('contributions.was_confirmed').empty?
  end

  def created_today?
    self.created_at.to_date == Date.today && self.sign_in_count <= 1
  end

  def to_analytics_json
    {
      id: self.id,
      email: self.email,
      total_contributed_projects: self.total_contributed_projects,
      total_created_projects: self.projects.count,
      created_at: self.created_at,
      last_sign_in_at: self.last_sign_in_at,
      sign_in_count: self.sign_in_count,
      created_today: self.created_today?
    }.to_json
  end

  def to_param
    return "#{self.id}" unless self.display_name
    "#{self.id}-#{self.display_name.parameterize}"
  end

  def project_unsubscribes
    contributed_projects.map do |project|
      unsubscribes.posts_unsubscribe(project.id)
    end
  end

  def subscribed_to_posts?
    unsubscribes.where(project_id: nil).empty?
  end

  def project_owner?
    projects.present?
  end

  def fix_twitter_user
    self.twitter.gsub!(/@/, '') if self.twitter
  end

  def nullify_permalink
    self.permalink = nil if self.permalink.blank?
  end

  def fix_facebook_link
    if self.facebook_link.present?
      self.facebook_link = ('http://' + self.facebook_link) unless self.facebook_link[/^https?:\/\//]
    end
  end

  def fix_other_link
    if self.other_link.present?
      self.other_link = ('http://' + self.other_link) unless self.other_link[/^https?:\/\//]
    end
  end

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def password_confirmation_required?
    !new_record?
  end

  def has_valid_contribution_for_project?(project_id)
    contributions.where(project_id: project_id).where('contributions.was_confirmed').present?
  end

  def generate_reset_password_token
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    self.save(validate: false)
    raw
  end

end
