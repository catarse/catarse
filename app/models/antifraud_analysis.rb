class AntifraudAnalysis < ApplicationRecord
  belongs_to :payment

  validates :payment_id, presence: true

  validates :payment_id, uniqueness: true
end
