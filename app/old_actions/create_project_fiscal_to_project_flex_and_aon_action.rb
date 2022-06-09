# frozen_string_literal: true

class CreateProjectFiscalToProjectFlexAndAonAction
  def initialize(project_id:)
    @project = Project.find project_id
  rescue StandardError => e
    Sentry.capture_exception(e, level: :fatal)
  end

  def call
    @project_data = new_project_data
    if @project_data.total_amount_to_pf_cents.positive? || @project_data.total_amount_to_pj_cents.positive?
      @project_data.save!
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
      end_date: end_date,
      created_at: DateTime.now,
      updated_at: DateTime.now
    }
  end

  def new_project_data
    # rubocop:disable Rails/SkipsModelValidations
    result = ProjectFiscal.upsert(
      new_project_data_attributes,
      returning: 'id',
      unique_by: %w[project_id begin_date end_date]
    )
    # rubocop:enable Rails/SkipsModelValidations
    @project.project_fiscals.find result.last&.dig('id')
  end

  def total_amount_to_pj
    query = Payment.joins(contribution: :user).where(
      contribution: { project_id: @project.id },
      user: { account_type: %w[pj mei] }, state: 'paid'
    )

    time_interval(query, 'payments', 'paid').sum(:value) * 100
  end

  def total_amount_to_pf
    query = Payment.joins(contribution: :user).where(
      contribution: { project_id: @project.id },
      user: { account_type: 'pf' }, state: 'paid'
    )

    time_interval(query, 'payments', 'paid').sum(:value) * 100
  end

  def total_irrf
    return 0 if total_catarse_fee > 666_660

    query = Payment.joins(contribution: :user).where(
      contribution: { project_id: @project.id },
      user: { account_type: %w[pj mei] }, state: 'paid'
    )

    0.015 * (time_interval(query, 'payments', 'paid').sum(:value) * 100)
  end

  def total_catarse_fee
    query = Payment.joins(:contribution).where(contribution: { project_id: @project.id }, state: 'paid')

    @project.service_fee * time_interval(query, 'payments', 'paid').sum(:value) * 100
  end

  def total_gateway_fee(state)
    query = Payment.joins(:contribution).where(contribution: { project_id: @project.id }, state: state)

    time_interval(query, 'payments', state).sum(:gateway_fee) * 100
  end

  def total_antifraud_fee(state)
    query = AntifraudAnalysis.joins(payment: :contribution)
      .where(contribution: { project_id: @project.id }, payment: { state: state })

    time_interval(query, 'antifraud_analyses', state).sum('COALESCE(cost, 0)') * 100
  end

  def total_chargeback_cost
    total_antifraud_fee('chargeback') + total_gateway_fee('chargeback')
  end

  def time_interval(query, type_query, state)
    return query.where(type_query => { created_at: begin_date..end_date, state: state }) if type_query == 'payments'

    query.where(type_query => { created_at: begin_date..end_date }, payment: { state: state })
  end

  def begin_date
    ProjectFiscal.where(project_id: @project.id)&.last&.created_at ||
      begin_date_from_payment ||
      @project.online_at.beginning_of_month
  end

  def begin_date_from_payment
    Payment.joins(:contribution).where(contribution: { project_id: @project.id }, state: 'paid')
      .order(:created_at).first&.created_at&.beginning_of_month
  end

  def end_date
    @project.successful_at || Time.zone.now.end_of_month
  end
end
