class StaticContent < ActiveRecord::Base
  validates_presence_of :title, :body

  auto_html_for :body do
    html_escape :map => {
      '&' => '&amp;',
      '>' => '&gt;',
      '<' => '&lt;',
      '"' => '"' }
    redcloth :target => :_blank
    link :target => :_blank
  end
end
