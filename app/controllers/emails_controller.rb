class EmailsController < ApplicationController
  def index
    render text: 'teste', layout: 'email'
  end
end
