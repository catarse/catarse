class Adm::BackersController < Adm::BaseController
  inherit_resources
  menu "Apoiadores" => Rails.application.routes.url_helpers.adm_backers_path
end
