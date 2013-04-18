class Channels::BaseController < ApplicationController
  skip_before_filter :set_locale
  before_filter do
    I18n.locale = 'pt'
  end
end
