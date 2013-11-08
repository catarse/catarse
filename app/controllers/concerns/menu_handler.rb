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

      def menu
        ApplicationController.menu_items.inject({}) do |memo, el|
          memo.merge!(el.first => Rails.application.routes.url_helpers.send(el.last)) if can? :access, el.last
          memo
        end
      end
    end

  end
end
