module Shared::CatarseAutoHtml
  extend ActiveSupport::Concern

  included do
    AutoHtml.add_filter(:email_image).with(width: 200) do |text, options|
      text.gsub(/http(s)?:\/\/.+\.(jpg|jpeg|bmp|gif|png)(\?\S+)?/i) do |match|
        width = options[:width]
        %|<img src="#{match}" alt="" style="max-width:#{width}px" />|
      end
    end

    def self.catarse_auto_html_for options={}
      self.auto_html_for options[:field] do
        html_escape map: {
          '&' => '&amp;',
          '>' => '&gt;',
          '<' => '&lt;',
          '"' => '"'
        }
        image
        youtube width: options[:video_width], height: options[:video_height], wmode: "opaque"
        vimeo width: options[:video_width], height: options[:video_height]
        redcloth target: :_blank
        link target: :_blank
      end
    end

    def catarse_email_auto_html_for field_data, options= {}
      self.auto_html field_data do
        html_escape map: {
          '&' => '&amp;',
          '>' => '&gt;',
          '<' => '&lt;',
          '"' => '"'
        }
        email_image width: options[:image_width]
        redcloth target: :_blank
        link target: :_blank
      end
    end
  end
end
