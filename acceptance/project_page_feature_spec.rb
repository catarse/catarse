# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')
feature "Project Page Feature" do
  scenario "when I access a project it should show me the facebook meta tags" do
    p = Factory(:project, :short_url => 'http://catr.se/teste')
    visit project_path(p.id)
    page.should have_css(%@meta [property="og:title"][content="#{p.name}"]@)
    page.should have_css(%@meta [property="og:type"][content="cause"]@)
#    page.should have_css(%@meta [property="og:url"][content="#{project_url(p.id)}"]@)
    page.should have_css(%@meta [property="og:image"][content="#{p.display_image}"]@)
    page.should have_css(%@meta [property="og:site_name"][content="#{I18n.t('site.name')}"]@)
    page.should have_css(%@meta [property="og:description"][content="#{p.about}"]@)
  end
end
