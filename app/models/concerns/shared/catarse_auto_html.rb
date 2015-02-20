module Shared::CatarseAutoHtml
  extend ActiveSupport::Concern

  included do
    AutoHtml.add_filter(:email_image).with(width: 200) do |text, options|
      text.gsub(/http(s)?:\/\/.+\.(jpg|jpeg|bmp|gif|png)(\?\S+)?/i) do |match|
        width = options[:width]
        %|<img src="#{match}" alt="" style="max-width:#{width}px" />|
      end
    end

    AutoHtml.add_filter(:add_alt_link_class) do |text, options|
      text.gsub(/<a/i, '<a class="alt-link"')
    end

    AutoHtml.add_filter(:add_line_breaks) do |text, options|
      text.gsub(/([^\n])\n([^\n])/i, '\1<br/>\2')
    end

    AutoHtml.add_filter(:named_link) do |text, options|
      text.gsub(/"(.+?)":([^\s,;<]+)/) do |match|
        "<a target=\"_blank\" href=\"#{$2}\">#{$1}</a>"
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
        named_link
        redcarpet target: :_blank
        link target: :_blank
        add_alt_link_class
        add_line_breaks
      end
    end

    def catarse_auto_html field_data, options= {}
      self.auto_html field_data do
        html_escape map: {
          '&' => '&amp;',
          '>' => '&gt;',
          '<' => '&lt;',
          '"' => '"'
        }
        email_image width: options[:image_width]
        named_link
        redcarpet target: :_blank
        link target: :_blank
        add_line_breaks
      end
    end
  end
end
