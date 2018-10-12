# encoding: utf-8
# frozen_string_literal: true

class RedactorRailsPictureUploader < ImageUploader
  include RedactorRails::Backend::CarrierWave

  # Include RMagick or ImageScience support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick
  # include CarrierWave::ImageScience

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end
  MAX_WIDTH = 667 * 2 # for retina displays

  process :read_dimensions
  process resize_to_limit: [MAX_WIDTH, -1], if: :not_gif?
  process gif_resize: [MAX_WIDTH, -1], if: :gif?


  # Create different versions of your uploaded files:
  version :thumb, if: :gif? do
    process gif_resize: [118, 100]
  end

  version :thumb, unless: :gif? do
    process resize_to_limit: [118, 100]
  end

  version :content, unless: :gif? do
    process resize_to_limit: [680, 800]
  end

  version :content, if: :gif? do
    process gif_resize: [680, 800]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    RedactorRails.image_file_types
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  private

  def gif?(new_file)
    new_file.content_type == "image/gif"
  end

  def not_gif?(new_file)
    !gif?(new_file)
  end

  def gif_safe_transform!
    MiniMagick::Tool::Convert.new do |convert| # Calls imagemagick's "convert" command
      convert << file.path
      convert.coalesce # Remove optimizations so each layer shows the full image.

      image = MiniMagick::Image.open(file.path)
      if image.width > MAX_WIDTH
        yield convert
      end

      convert.layers "Optimize" # Re-optimize the image.
      convert << file.path
    end
  end

  def gif_resize(w,h)
    gif_safe_transform! do |image|
      image.resize "#{w}x#{h}"
    end
  end
end
