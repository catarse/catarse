# frozen_string_literal: true

Rails.application.routes.draw do
  mount CatarseScripts::Engine => '/catarse_scripts'
end
