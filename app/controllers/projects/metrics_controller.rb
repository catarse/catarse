class Projects::MetricsController < ApplicationController
  after_filter :verify_authorized
  respond_to :html
  layout false

  def index
    authorize parent

    @metrics ||= {}

    confirmed_amount_by_day
    total_confirmed_by_day
    total_by_address_state
    respond_with @metrics
  end

  protected

  def total_by_address_state
    @metrics[:address_state] = collection.with_state('confirmed').
      joins(:user).group("upper(users.address_state)").count
  end

  def total_confirmed_by_day
    @metrics[:confirmed] = collection.with_state('confirmed').
      group("contributions.created_at::date").
      count
  end

  def confirmed_amount_by_day
    @metrics[:confirmed_amount_by_day] = collection.with_state('confirmed').
      group("contributions.created_at::date").
      sum(:value)
  end

  def collection
    @contributions ||= parent.contributions.
      where.not("contributions.created_at::date = current_timestamp::date")
  end

  def parent
    @project ||= Project.find params[:id]
  end

end
