# frozen_string_literal: true

class CategoryDecorator < Draper::Decorator
  decorates :category
  include Draper::LazyHelpers

  def display_name
    I18n.available_locales.include?(params[:locale].to_sym) ? object.send('name_' + params[:locale]) : object.name_pt
  end
end
