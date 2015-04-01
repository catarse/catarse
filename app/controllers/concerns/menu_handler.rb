module Concerns
  module MenuHandler
    extend ActiveSupport::Concern

    included do
      @@menu_items = {}
      cattr_accessor :menu_items

      def self.add_to_menu i18n_name, path
        menu I18n.t(i18n_name) => path
      end

      def self.menu menu
        self.menu_items.merge! menu
      end

      # Only admin can access
      add_to_menu "admin.contributions.index.menu", :admin_contributions_path
      add_to_menu "admin.financials.index.menu",    :admin_financials_path
      add_to_menu "admin.users.index.menu",         :admin_users_path
      add_to_menu "admin.projects.index.menu",      :admin_projects_path
      menu "Dataclips" => :dbhero_path

      def menu
        ApplicationController.menu_items.inject({}) do |memo, el|
          if current_user.admin?
            memo.merge!(el.first => Rails.application.routes.url_helpers.send(el.last))
          end
          memo
        end
      end
    end

  end
end
