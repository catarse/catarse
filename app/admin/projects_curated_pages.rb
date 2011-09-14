ActiveAdmin.register ProjectsCuratedPage do
  index do
    column :project do |pcp|
      pcp.project.name
    end
    column :curated_page do |pcp|
      pcp.curated_page.name
    end
    default_actions
  end
end