# frozen_string_literal: true

class ProjectFiscal < ApplicationRecord
  belongs_to :user
  belongs_to :project

  validates :user_id, presence: true
  validates :project_id, presence: true
  validates :begin_date, presence: true
  validates :end_date, presence: true

  monetize :total_amount_cents, numericality: { greater_than_or_equal_to: 1 }
  monetize :total_catarse_fee_cents, numericality: { greater_than_or_equal_to: 1 }
  monetize :total_gateway_fee_cents, numericality: { greater_than_or_equal_to: 1 }

  def total_debit_invoice
    total_catarse_fee_cents - total_gateway_fee_cents - total_antifraud_fee_cents
  end
end
