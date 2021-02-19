# frozen_string_literal: true

class BalanceTransfer < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
end
