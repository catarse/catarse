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
    @project_data = new_project_data
    if @project_data.total_amount_to_pf_cents.positive? || @project_data.total_amount_to_pj_cents.positive?
      cut_off_date = CatarseSettings[:enotes_initial_cut_off_date]
      if cut_off_date && @project_data.end_date >= cut_off_date.to_date
        metadata = ENotas::Client.new.create_nfe(ENotas::ParamsBuilders::Order.new(@project_data).build)
        @project_data.update(metadata: metadata)
      end
      @project_data
    end
  rescue StandardError => e
    Sentry.capture_exception(e, level: :fatal)
  end

  private

  def new_project_data_attributes
    {
      user_id: @project.user_id,
      project_id: @project.id,
      total_amount_to_pf_cents: total_amount_to_pf,
      total_amount_to_pj_cents: total_amount_to_pj,
      total_catarse_fee_cents: total_catarse_fee,
      total_gateway_fee_cents: total_gateway_fee('paid'),
      total_antifraud_fee_cents: total_antifraud_fee('paid'),
      total_chargeback_cost_cents: total_chargeback_cost,
      total_irrf_cents: total_irrf,
      begin_date: begin_date,
      end_date: end_date
    }
  end

  def new_project_data
    # rubocop:disable Rails/SkipsModelValidations
    id = ProjectFiscal.upsert(
      new_project_data_attributes,
      returning: 'id',
      unique_by: %w[project_id begin_date end_date]
    )
    # rubocop:enable Rails/SkipsModelValidations
    @project.project_fiscals.find id
  end

  def total_amount_to_pj
    subscription_payments_in_time.joins(:user).where(user: { account_type: %w[pj mei] }).sum { |s| s.amount } * 100
  end

  def total_amount_to_pf
    subscription_payments_in_time.joins(:user).where(user: { account_type: %w[pf] }).sum { |s| s.amount } * 100
  end

  def total_irrf
    return 0 if total_catarse_fee > 666_660

    0.015 * total_amount_to_pj
  end

  def total_catarse_fee(state = 'paid')
    sum_amount = subscription_payments_in_time(state).sum { |s| s.amount }

    (@project.service_fee * sum_amount) * 100
  end

  def total_gateway_fee(state)
    subscription_payments_in_time(state).sum { |s| s.gateway_fee } * 100
  end

  def total_antifraud_fee(state)
    af_cost = subscription_payments_in_time(state).reduce(0) do |amount, item|
      item.antifraud_analyses.each do |af|
        amount += af.cost
      end

      amount
    end

    af_cost * 100
  end

  def total_chargeback_cost
    total_antifraud_fee('chargedback') + total_gateway_fee('chargedback')
  end

  def subscription_payments_in_time(state = 'paid')
    @project.subscription_payments.where(created_at: begin_date..end_date, status: state)
  end

  def begin_date
    "#{@year}-#{@month}-01".to_date.beginning_of_month
  end

  def end_date
    "#{@year}-#{@month}-01".to_date.end_of_month
  end
end
