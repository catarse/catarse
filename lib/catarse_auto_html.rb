module CatarseAutoHtml
  def catarse_auto_html_for options={}
    self.auto_html_for options[:field] do
      html_escape :map => {
        '&' => '&amp;',
        '>' => '&gt;',
        '<' => '&lt;',
        '"' => '"' }
      image
      youtube width: options[:video_width], height: options[:video_height], wmode: "opaque"
      vimeo width: options[:video_width], height: options[:video_height]
      redcloth :target => :_blank
      link :target => :_blank
    end
  end
end
