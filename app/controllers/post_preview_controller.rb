class PostPreviewController < ApplicationController
  include AutoHtml
  layout false

  def show
    render text: convert_to_html
  end

  protected

  def convert_to_html
    auto_html(params[:text]) do
      html_escape map: {
        '&' => '&amp;',
        '>' => '&gt;',
        '<' => '&lt;',
        '"' => '"'
      }
      image width: 600
      named_link
      youtube width: 600, height: 403, wmode: "opaque"
      vimeo width: 600, height: 403
      redcarpet target: :_blank
      link target: :_blank
    end
  end

end
