class CuratedPage < ActiveRecord::Base
  has_many :projects
  belongs_to :site

  validates_uniqueness_of :permalink, :scope => :site_id
  validates_presence_of :permalink, :name, :site, :logo

  mount_uploader :logo, LogoUploader

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
