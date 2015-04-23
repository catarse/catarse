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
    @metrics[:address_state] = collection.joins(:user).group("upper(users.address_state)").count
  end

  def total_confirmed_by_day
    @metrics[:confirmed] = collection.joins(:payments).group("
      payments.paid_at::date AT TIME ZONE '#{Time.zone.tzinfo.name}'
    ").count
  end

  def confirmed_amount_by_day
    @metrics[:confirmed_amount_by_day] = collection.joins(:payments).group("
      payments.paid_at::date AT TIME ZONE '#{Time.zone.tzinfo.name}'"
    ).sum(:value)
  end

  def collection
    @contributions ||= parent.contributions.where('contributions.was_confirmed')
  end

  def parent
    @project ||= Project.find params[:id]
  end

end
