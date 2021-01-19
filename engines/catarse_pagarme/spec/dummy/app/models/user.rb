class User < ActiveRecord::Base
  has_many :projects
  has_many :contributions
  has_many :credit_cards
  has_one :user_total
  has_one :bank_account

  accepts_nested_attributes_for :bank_account

  def credits
    user_total.present? ? user_total.credits : 0
  end
end
