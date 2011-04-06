# coding: utf-8
class CommentsController < ApplicationController
  inherit_resources
  actions :index, :show, :create, :destroy
  respond_to :json
end