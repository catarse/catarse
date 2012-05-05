xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do

  xml.url do
    xml.loc "http://catarse.me"
    xml.priority 1.0
    xml.changefreq "daily"
  end

  %w[pt en].each do |locale|
    xml.url do
      xml.loc "http://catarse.me/#{locale}"
      xml.priority 0.9
      xml.changefreq "daily"
    end
    %w[guidelines faq terms privacy].each do |static|
      xml.url do
        xml.loc "http://catarse.me/#{locale}/#{static}"
        xml.priority 0.1
        xml.changefreq "monthly"
      end
    end
  end

  @home_page.each do |project|
    xml.url do
      xml.loc project_url(project)
      xml.priority 0.6
      xml.changefreq "daily"
      xml.lastmod project.updated_at.to_date
    end
  end

  @expiring.each do |project|
    xml.url do
      xml.loc project_url(project)
      xml.priority 0.8
      xml.changefreq "daily"
      xml.lastmod project.updated_at.to_date
    end
  end

  @recent.each do |project|
    xml.url do
      xml.loc project_url(project)
      xml.priority 0.4
      xml.changefreq "daily"
      xml.lastmod project.updated_at.to_date
    end
  end

  @successful.each do |project|
    xml.url do
      xml.loc project_url(project)
      xml.priority 0.2
      xml.changefreq "daily"
      xml.lastmod project.updated_at.to_date
    end
  end

end