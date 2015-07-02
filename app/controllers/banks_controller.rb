class BanksController < ApplicationController
  def show
    @bank = Bank.find_by_code params[:id]
    render json: @bank.to_json
  end
end
