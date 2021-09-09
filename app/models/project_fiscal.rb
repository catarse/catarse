# frozen_string_literal: true

class ProjectFiscal < ApplicationRecord
  belongs_to :user
  belongs_to :project

  validates :user_id, presence: true
  validates :project_id, presence: true
  validates :begin_date, presence: true
  validates :end_date, presence: true

  monetize :total_amount_to_pj_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :total_amount_to_pf_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :total_catarse_fee_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :total_antifraud_fee_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :total_gateway_fee_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :total_irrf_cents, numericality: { greater_than_or_equal_to: 0 }

  def total_debit_invoice
    (total_catarse_fee_cents - total_gateway_fee_cents - total_antifraud_fee_cents) * 100
  end

  def total_amount
    total_amount_to_pj_cents + total_amount_to_pf_cents
  end
end
