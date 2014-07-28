class FeedbacksController < ApplicationController
  def create
    form = FeedbackForm.new permitted_params[:feedback]
    form.deliver
    render json: true
  end

  private
  def permitted_params
    params.permit(feedback: [:email, :message])
  end
end

