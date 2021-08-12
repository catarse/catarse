# frozen_string_literal: true

class CreateProjectFiscalToProjectSubAction
  def initialize(project_id:, month:, year:)
    @project = Project.find project_id
    @month = month
    @year = year
  rescue StandardError => e
    Sentry.capture_exception(e, level: :fatal)
  end

  def call
    create_project_data
  rescue StandardError => e
    Sentry.capture_exception(e, level: :fatal)
  end

  private

  def create_project_data
    ProjectFiscal.create(
      user_id: @project.user_id,
      project_id: @project.id,
      total_amount_cents: total_amount,
      total_catarse_fee_cents: total_catarse_fee,
      total_gateway_fee_cents: total_geteway_fee('paid'),
      total_antifraud_fee_cents: total_antifraud_fee('paid'),
      total_chargeback_cost_cents: total_chargeback_cost,
      begin_date: begin_date,
      end_date: end_date
    )
  end

  def total_amount
    query = Payment.joins(:contribution).where(contribution: { project_id: @project.id }, state: 'paid')

    time_interval(query, 'payments', 'paid').sum(:value)
  end

  def total_catarse_fee
    query = Payment.joins(:contribution).where(contribution: { project_id: @project.id }, state: 'paid')

    @project.service_fee * time_interval(query, 'payments', 'paid').sum(:value)
  end

  def total_geteway_fee(state)
    query = Payment.joins(:contribution).where(contribution: { project_id: @project.id }, state: state)

    time_interval(query, 'payments', state).sum(:gateway_fee)
  end

  def total_antifraud_fee(state)
    query = AntifraudAnalysis.joins(payment: :contribution)
      .where(contribution: { project_id: @project.id }, payment: { state: state })

    time_interval(query, 'antifraud_analyses', state).sum('COALESCE(cost, 0)')
  end

  def total_chargeback_cost
    total_antifraud_fee('chargeback') + total_geteway_fee('chargeback')
  end

  def time_interval(query, type_query, state)
    return query.where(type_query => { created_at: begin_date..end_date, state: state }) if type_query == 'payments'

    query.where(type_query => { created_at: begin_date..end_date }, payment: { state: state })
  end

  def begin_date
    "#{@year}-#{@month}-01".to_date.beginning_of_month
  end

  def end_date
    "#{@year}-#{@month}-01".to_date.end_of_month
  end
end
