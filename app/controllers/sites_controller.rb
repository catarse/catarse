# coding: utf-8
class SitesController < ApplicationController
  def show
    return unless require_admin
    session[:current_site] = params[:id]
    redirect_to :root
  end
end
