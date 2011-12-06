class CuratedPage < ActiveRecord::Base

  has_many :projects_curated_pages
  has_many :projects, :through => :projects_curated_pages

  validates_uniqueness_of :permalink
  validates_presence_of :permalink, :name, :logo

  scope :visible, where("visible is true")
  scope :not_visible, where("visible is not true")

  mount_uploader :logo, LogoUploader

  auto_html_for :description do
    html_escape :map => { 
      '&' => '&amp;',  
      '>' => '&gt;',
      '<' => '&lt;',
      '"' => '"' }
    redcloth :target => :_blank
    link :target => :_blank
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

end
