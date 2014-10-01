class Bank < ActiveRecord::Base
  has_many :bank_accounts

  validates :name, :code, presence: true

  def self.to_collection
    self.order(:name).map do |bank|
      [bank.to_s, bank.id]
    end
  end

  def to_s
    [code, name].join(' . ')
  end
end
