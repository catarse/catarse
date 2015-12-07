atom_feed language: 'pt-BR' do |feed|
  feed.title t('pages.explore.title')
  feed.updated Time.now

  projects.each do |project|
    feed.entry(project, published: project.online_date, url: project_by_slug_url(permalink: project.permalink)) do |entry|
      entry.url project_by_slug_url(permalink: project.permalink)
      entry.title project.name
      entry.logo project.display_image(:project_thumb_large)
      entry.content project.headline, type: 'html'
      entry.author do |author|
        author.name project.user.display_name
      end
    end
  end
end
