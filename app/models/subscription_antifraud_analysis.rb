# frozen_string_literal: true

class SubscriptionAntifraudAnalysis < ApplicationRecord
  include Shared::CommonWrapper

  self.table_name = 'common_schema.antifraud_analyses'
  self.primary_key = :id

  belongs_to :subscription_payment, foreign_key: 'catalog_payment_id', inverse_of: :antifraud_analyses
end
