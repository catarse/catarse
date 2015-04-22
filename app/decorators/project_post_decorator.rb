class ProjectPostDecorator < Draper::Decorator
  decorates :project_post
  include Draper::LazyHelpers

  def email_comment_html
    doc = Nokogiri::HTML(source.comment_html)
    doc.xpath('//iframe').each do |iframe|
      src = iframe.attr('src')
      link = doc.create_element 'a'
      link['href'] = src.gsub(/^\/\//,'http://')
      link.content = src.gsub(/^\/\//,'')
      iframe.replace link
    end
    return doc.at('body').inner_html
  end

end
