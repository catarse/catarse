class Channels::AdmProjectsController < Adm::ProjectsController
  self.menu I18n.t('channels.adm.menu') => Rails.application.routes.url_helpers.channels_adm_projects_url
  
end
