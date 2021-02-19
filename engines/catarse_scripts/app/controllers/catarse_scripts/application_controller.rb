# frozen_string_literal: true

module CatarseScripts
  class ApplicationController < ActionController::Base
    include Pagy::Backend
  end
end
