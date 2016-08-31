# coding: utf-8
class User < ActiveRecord::Base
  include I18n::Alchemy
  acts_as_token_authenticatable
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
  delegate :bank, to: :bank_account

  # FIXME: Please bitch...
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :permalink,
    :image_url, :uploaded_image, :newsletter, :address_street, :address_number,
    :address_complement, :address_neighbourhood, :address_city, :address_state, :address_zip_code, :phone_number,
    :cpf, :state_inscription, :locale, :twitter, :facebook_link, :other_link, :moip_login, :deactivated_at, :reactivate_token,
    :bank_account_attributes, :country_id, :zero_credits, :links_attributes, :about_html, :cover_image, :category_followers_attributes, :category_follower_ids,
    :subscribed_to_project_posts, :subscribed_to_new_followers, :subscribed_to_friends_contributions

  mount_uploader :uploaded_image, UserUploader
  mount_uploader :cover_image, CoverUploader


  validates_presence_of :email
  validates_uniqueness_of :email, allow_blank: true, if: :email_changed?, message: I18n.t('activerecord.errors.models.user.attributes.email.taken')
  validates_uniqueness_of :permalink, allow_nil: true
  validates :permalink,  exclusion: { in: %w(api cdn secure suporte),
    message: "Endereço já está em uso." }
  validates_format_of :email, with: Devise.email_regexp, allow_blank: true, if: :email_changed?

  validates_presence_of :password, if: :password_required?
  validates_confirmation_of :password, if: :password_confirmation_required?
  validates_length_of :password, within: Devise.password_length, allow_blank: true

  belongs_to :country
  has_one :user_total
  has_one :user_credit
  has_one :bank_account, dependent: :destroy
  has_many :user_friends
  has_many :feeds, class_name: 'UserFeed'
  has_many :follows, class_name: 'UserFollow'
  has_many :credit_cards
  has_many :project_accounts
  has_many :authorizations
  has_many :contributions
  has_many :contribution_details
  has_many :reminders, class_name: 'ProjectReminder', inverse_of: :user
  has_many :payments, through: :contributions
  has_many :projects, -> do
    without_state(:deleted)
  end
  has_many :published_projects, -> do
    with_states(Project::PUBLISHED_STATES)
  end, class_name: 'Project'
  has_many :unsubscribes
  has_many :user_transfers
  has_many :project_posts
  has_many :donations
  has_many :public_contributed_projects, -> do
    distinct.where("contributions.was_confirmed and anonymous='f'")
  end, through: :contributions, source: :project
  has_many :contributed_projects, -> do
    distinct.where("contributions.was_confirmed")
  end, through: :contributions, source: :project
  has_many :category_followers, dependent: :destroy
  has_many :categories, through: :category_followers
  has_many :links, class_name: 'UserLink', inverse_of: :user
  has_and_belongs_to_many :recommended_projects, join_table: :recommendations, class_name: 'Project'

  accepts_nested_attributes_for :unsubscribes, allow_destroy: true rescue puts "No association found for name 'unsubscribes'. Has it been defined yet?"
  accepts_nested_attributes_for :links, allow_destroy: true, reject_if: ->(x) { x['link'].blank? }
  accepts_nested_attributes_for :bank_account, allow_destroy: true, reject_if: -> (attr) { attr[:bank_id].blank? }
  accepts_nested_attributes_for :category_followers, allow_destroy: true

  scope :with_permalink, -> { where.not(permalink: nil) }
  scope :active, ->{ where(deactivated_at: nil) }
  scope :with_user_totals, -> {
    joins("LEFT OUTER JOIN user_totals on user_totals.user_id = users.id")
  }

  scope :who_contributed_project, ->(project_id) {
    where("id IN (SELECT user_id FROM contributions WHERE contributions.was_confirmed AND project_id = ?)", project_id)
  }

  scope :subscribed_to_posts, -> {
     where("subscribed_to_project_posts")
   }

  scope :with_contributing_friends_since_last_day, -> {
    joins("join user_follows on user_follows.user_id = users.id").
      where("(EXISTS (
        SELECT true 
        from contributions
        join payments on payments.contribution_id = contributions.id 
        WHERE user_follows.follow_id = contributions.user_id 
            and contributions.is_confirmed 
            and not contributions.anonymous
            and payments.paid_at > CURRENT_TIMESTAMP - '1 day'::interval
            ))")
  }

  scope :subscribed_to_project, ->(project_id) {
    who_contributed_project(project_id).
    where("id NOT IN (SELECT user_id FROM unsubscribes WHERE project_id = ?)", project_id)
  }

  #FIXME: very slow query
  # This query is executed once a day in worst case and taks 1/2 second to excute
  # LGTM
  scope :to_send_category_notification, -> (category_id) {
    where("NOT EXISTS (
          select true from category_notifications n
          where n.template_name = 'categorized_projects_of_the_week' AND
          n.category_id = ? AND
          (current_timestamp - n.created_at) <= '1 week'::interval AND
          n.user_id = users.id)", category_id)
  }

  scope :order_by, ->(sort_field){ order(sort_field) }

  def self.followed_since_last_day
    where(id: UserFollow.since_last_day.pluck(:follow_id))
  end

  def self.find_active!(id)
    self.active.where(id: id).first!
  end

  def followers_since_last_day
    followers.where(created_at: Time.current - 1.day .. Time.current)
  end

  def has_fb_auth?
    @has_fb_auth ||= fb_auth.present?
  end

  def fb_auth
    @fb_auth ||= authorizations.facebook.first
  end

  # Return the projects that user has pending refund payments
  def pending_refund_payments_projects
    pending_refund_payments.map(&:project)
  end

  # Return the pending payments to refund for failed projects
  def pending_refund_payments
    payments.joins(contribution: :project).where({
      projects: {
        state: 'failed'
      },
      state: 'paid',
      gateway: 'Pagarme',
      payment_method: 'BoletoBancario'
    }).select do |payment|
      !payment.already_in_refund_queue?
    end
  end

  def has_pending_legacy_refund?
    user_transfers.where(status: ['pending_transfer', 'processing']).exists?
  end

  #in cents
  def credits_amount
    (credits * 100).to_i
  end

  def has_online_project?
    projects.with_state('online').exists?
  end

  def has_sent_notification?
    projects.any? {|p| p.posts.exists?}
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
    self.update_attributes deactivated_at: Time.current, reactivate_token: Devise.friendly_token
    self.contributions.update_all(anonymous: true)
  end

  def made_any_contribution_for_this_project?(project_id)
    contribution_details.was_confirmed.where(project_id: project_id).exists?
  end

  def decorator
    @decorator ||= UserDecorator.new(self)
  end

  def credits
    return 0 if zero_credits
    user_credit.try(:credits).to_f
  end

  def total_contributed_projects
    user_total.try(:total_contributed_projects).to_i
  end

  def contributing_friends_since_last_day(project)
    follows.joins('join contributions on contributions.user_id = user_follows.follow_id 
                    join payments on payments.contribution_id = contributions.id
                    join projects on projects.id = contributions.project_id').
                  where("contributions.is_confirmed 
                        and not contributions.anonymous 
                        and payments.paid_at > CURRENT_TIMESTAMP - '1 day'::interval and projects.id = ?", project.id).uniq
  end

  def projects_backed_by_friends_in_last_day
    Project.joins(:contributions).
      joins('join user_follows on user_follows.follow_id = contributions.user_id
            join payments on payments.contribution_id = contributions.id').
            where('contributions.is_confirmed and not contributions.anonymous').
            where("payments.paid_at > CURRENT_TIMESTAMP - '1 day'::interval
                  and user_follows.user_id = ?", self.id).uniq
  end

  def has_no_confirmed_contribution_to_project(project_id)
    contributions.where(project_id: project_id).where('contributions.was_confirmed').empty?
  end

  def created_today?
    self.created_at.to_date == Time.zone.today && self.sign_in_count <= 1
  end

  def to_analytics
    {
      user_id: self.id,
      email: self.email,
      name: self.name,
      contributions: self.total_contributed_projects,
      projects: self.projects.count,
      published_projects: self.published_projects.count,
      created: self.created_at,
      has_fb_auth: self.has_fb_auth?,
      has_online_project: self.has_online_project?,
      has_created_post: self.has_sent_notification?,
      last_login: self.last_sign_in_at,
      created_today: self.created_today?,
      follows_count: follows.count,
      followers_count: followers.count,
      is_admin_role: self.admin? || false
    }
  end

  def to_analytics_json
    to_analytics.to_json
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
    if self.twitter.present?
      splited = self.twitter.split("/").last
      self.twitter = splited.gsub(/@/, '') if splited.present?
    end
  end

  def nullify_permalink
    self.permalink = nil if self.permalink.blank?
  end

  def fix_facebook_link
    if self.facebook_link.present?
      self.facebook_link = ('http://' + self.facebook_link) unless self.facebook_link[/^https?:\/\//]
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

  def followers
    @followers ||= UserFollow.where(follow_id: id).where.not(user_id: id)
  end

  def generate_reset_password_token
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    self.save(validate: false)
    raw
  end

end
