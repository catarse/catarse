# coding: utf-8
class SitesController < ApplicationController
  def show
    session[:current_site] = params[:id]
    redirect_to :root
  end
end
