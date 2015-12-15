class CategoryDecorator < Draper::Decorator
  decorates :category
  include Draper::LazyHelpers

  def display_name
    I18n.available_locales.include?(params[:locale].to_sym) ? source.send('name_'+params[:locale]) : source.name_pt
  end
end
