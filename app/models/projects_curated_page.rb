class ProjectsCuratedPage < ActiveRecord::Base
  belongs_to :project
  belongs_to :curated_page
  validates_presence_of :project, :curated_page

  auto_html_for :description do
    html_escape :map => { 
      '&' => '&amp;',  
      '>' => '&gt;',
      '<' => '&lt;',
      '"' => '"' }
    redcloth :target => :_blank
    link :target => :_blank
  end
end
