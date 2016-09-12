# -*- coding: utf-8 -*-

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = CatarseSettings[:base_url]

# The remote host where your sitemaps will be hosted
SitemapGenerator::Sitemap.sitemaps_host = CatarseSettings[:sitemap_host]

# The directory to write sitemaps to locally
SitemapGenerator::Sitemap.public_path = 'tmp/'

# Set this to a directory/path if you don't want to upload to the root of your `sitemaps_host`
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
 
SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new(
  fog_provider: 'AWS',
  aws_access_key_id: CatarseSettings[:aws_access_key],
  aws_secret_access_key: CatarseSettings[:aws_secret_key],
  fog_directory: CatarseSettings[:sitemap_bucket]
)

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  #Páginas estáticas
  add '/start'
  add '/explore'
  add '/flex' #deixemos aqui para que a palavra seja indexada?
  add '/team'
  add '/jobs'
  add '/press'
  add '/terms-of-use'
  add '/privacy-policy'

  #Outros sites
  add '/', :host => 'http://pesquisa.catarse.me/'
  add '/', :host => 'http://crowdfunding.catarse.me'
  add '/amigos', :host => 'http://crowdfunding.catarse.me'
  add '/paratodos', :host => 'http://crowdfunding.catarse.me'
  add '/guia-financiamento-coletivo', :host => 'http://fazum.catarse.me'

  #Projetos
  Project.where("permalink in ('mola','alendadoheroi') or state in ('online','waiting_funds') or expires_at+'7 days'::interval > now() or (state='successful' and (mode='aon' or goal*0.50<(select sum(p.value) from payments p join contributions c on c.id=p.contribution_id and p.state='paid' and c.project_id=projects.id)))").update_ordered.each do |project|
    add project.permalink, :lastmod => project.updated_at,\
      :priority => (project.state!='successful' ? 0.6 : 0.4),\
      :changefreq => (project.state!='successful' ? 'daily' : 'yearly')
  end
end
