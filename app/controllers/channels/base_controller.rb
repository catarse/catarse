class Channels::BaseController < ApplicationController
  skip_before_filter :set_locale
end
