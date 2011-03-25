# coding: utf-8
VIMEO_REGEX = /\Ahttp:\/\/(www\.)?vimeo.com\/(\d+)\z/
class Project < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper
  include ERB::Util
  include Rails.application.routes.url_helpers
  belongs_to :user
  belongs_to :category
  has_many :backers
  has_many :rewards
  accepts_nested_attributes_for :rewards
  scope :visible, where(:visible => true)
  scope :home_page, where(:home_page => true)
  scope :not_home_page, where(:home_page => false)
  scope :recommended, where(:recommended => true)
  scope :not_recommended, where(:recommended => false)
  scope :pending, where(:visible => false, :rejected => false)
  scope :expiring, where("expires_at >= current_timestamp AND expires_at < (current_timestamp + interval '2 weeks')")
  scope :recent, where("created_at > (current_timestamp - interval '1 month')")
  scope :successful, where("goal <= (SELECT sum(value) FROM backers WHERE project_id = projects.id AND confirmed) AND expires_at < current_timestamp")
  scope :not_successful, where("NOT (goal <= (SELECT sum(value) FROM backers WHERE project_id = projects.id AND confirmed) AND expires_at < current_timestamp)")
  scope :unsuccessful, where("goal > (SELECT sum(value) FROM backers WHERE project_id = projects.id AND confirmed) AND expires_at < current_timestamp")
  scope :not_unsuccessful, where("NOT (goal > (SELECT sum(value) FROM backers WHERE project_id = projects.id AND confirmed) AND expires_at < current_timestamp)")
  validates_presence_of :name, :user, :category, :about, :headline, :goal, :expires_at, :video_url
  validates_length_of :headline, :maximum => 140
  validates_format_of :video_url, :with => VIMEO_REGEX, :message => "somente URLs do Vimeo são aceitas"
  validate :verify_if_video_exists_on_vimeo
  before_create :store_image_url
  def store_image_url
    self.image_url = vimeo["thumbnail_large"] unless self.image_url
  end
  def verify_if_video_exists_on_vimeo
    unless vimeo and vimeo["id"] == vimeo_id
      errors.add(:video_url, "deve existir no Vimeo")
    end
  end
  def to_param
    "#{self.id}-#{self.name.parameterize}"
  end
  def vimeo
    return @vimeo if @vimeo
    return unless vimeo_id
    @vimeo = Vimeo::Simple::Video.info(vimeo_id)
    if @vimeo.parsed_response and @vimeo.parsed_response[0]
      @vimeo = @vimeo.parsed_response[0]
    else
      @vimeo = nil
    end
  rescue
    @vimeo = nil
  end
  def vimeo_id
    return @vimeo_id if @vimeo_id
    return unless video_url
    if result = video_url.match(VIMEO_REGEX)
      @vimeo_id = result[2]
    end
  end
  def video_embed_url
    "http://player.vimeo.com/video/#{vimeo_id}"
  end
  def display_image
    return image_url if image_url
    return "user.png" unless vimeo and vimeo["thumbnail_large"]
    vimeo["thumbnail_large"]
  end
  def display_about
    h(about).gsub("\n", "<br>").html_safe
  end
  def display_expires_at
    expires_at.strftime('%d/%m')
  end
  def display_pledged
    number_to_currency pledged, :unit => 'R$ ', :precision => 0, :delimiter => '.'
  end
  def display_goal
    number_to_currency goal, :unit => 'R$ ', :precision => 0, :delimiter => '.'
  end
  def pledged
    backers.confirmed.sum(:value)
  end
  def total_backers
    backers.confirmed.count
  end
  def successful?
    pledged >= goal
  end
  def expired?
    expires_at < Time.now
  end
  def waiting_confirmation?
    return false if successful?
    expired? and Time.now < 3.weekdays_from(expires_at)
  end
  def in_time?
    expires_at >= Time.now
  end
  def percent
    ((pledged / goal * 100).abs).round.to_i
  end
  def display_percent
    return 100 if successful?
    return 8 if percent > 0 and percent < 8
    percent
  end
  def time_to_go
    if expires_at >= 1.day.from_now
      time = ((expires_at - Time.now).abs/60/60/24).round
      {:time => time, :unit => pluralize_without_number(time, 'dia')}
    elsif expires_at >= 1.hour.from_now
      time = ((expires_at - Time.now).abs/60/60).round
      {:time => time, :unit => pluralize_without_number(time, 'hora')}
    elsif expires_at >= 1.minute.from_now
      time = ((expires_at - Time.now).abs/60).round
      {:time => time, :unit => pluralize_without_number(time, 'minuto')}
    elsif expires_at >= 1.second.from_now
      time = ((expires_at - Time.now).abs).round
      {:time => time, :unit => pluralize_without_number(time, 'segundo')}
    else
      {:time => 0, :unit => 'segundos'}
    end
  end
  def can_back?
    visible and not expired? and not rejected
  end
  def finish!
    return unless expired? and can_finish and not finished
    backers.confirmed.each do |backer|
      unless backer.can_refund
        if successful?
          notification_text = "Uhuu! O projeto #{link_to(truncate(name, :length => 38), "/projects/#{self.to_param}")} que você apoiou foi bem-sucedido! Espalhe por aí!"
          twitter_text = "Uhuu! O projeto '#{name}', que eu apoiei, foi bem-sucedido no @Catarse_! #{short_url}"
          facebook_text = "Uhuu! O projeto '#{name}', que eu apoiei, foi bem-sucedido no Catarse!"
          email_subject = "Uhuu! O projeto que você apoiou foi bem-sucedido no Catarse!"
          email_text = "O projeto #{link_to(name, "#{BASE_URL}/projects/#{self.to_param}", :style => 'color: #008800;')}, que você apoiou, foi financiado com sucesso no Catarse! Hora de comemorar :D<br><br>Muito obrigado, de coração, pelo seu apoio! Sem ele, isto jamais seria possível. Em breve, #{link_to(user.display_name, "#{BASE_URL}/users/#{user.to_param}", :style => 'color: #008800;')} irá entrar em contato com você para entregar sua recompensa. Enquanto isso, compartilhe com todo mundo este sucesso!"
          backer.user.notifications.create :project => self, :text => notification_text, :twitter_text => twitter_text, :facebook_text => facebook_text, :email_subject => email_subject, :email_text => email_text
          if backer.reward
            notification_text = "Em breve, #{link_to(truncate(user.display_name, :length => 32), "/users/#{user.to_param}")} irá entrar em contato com você para entregar sua recompensa. Disfrute!"
            backer.user.notifications.create :project => self, :text => notification_text
          end
        else
          backer.generate_credits!
          notification_text = "O projeto #{link_to(truncate(name, :length => 32), "/projects/#{self.to_param}")} que você apoiou não foi financiado. Quem sabe numa próxima vez?"
          backer.user.notifications.create :project => self, :text => notification_text
          notification_text = "Você recebeu #{backer.display_value} em créditos para apoiar outros projetos. Caso prefira, você pode pedir seu dinheiro de volta #{link_to "aqui", "#{BASE_URL}/credits"}."
          email_subject = "O projeto que você apoiou não foi financiado no Catarse."
          email_text = "O projeto #{link_to(name, "#{BASE_URL}/projects/#{self.to_param}", :style => 'color: #008800;')}, que você apoiou, não foi financiado. Quem sabe numa próxima vez?<br><br>Em função disto, você recebeu <strong>#{backer.display_value}</strong> em créditos para apoiar outros projetos. Caso prefira, você pode pedir seu dinheiro de volta #{link_to "clicando aqui", "#{BASE_URL}/credits", :style => 'color: #008800;'}."
          backer.user.notifications.create :project => self, :text => notification_text, :email_subject => email_subject, :email_text => email_text
        end
      end
    end
    self.update_attribute :finished, true
  end
end
