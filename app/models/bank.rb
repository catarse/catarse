class Bank < ActiveRecord::Base
  has_many :bank_accounts

  validates :name, :code, presence: true
  scope :order_popular, ->{
    select('banks.code, banks.id, banks.name, count(bank_accounts.bank_id) as total').
    joins('left join bank_accounts on bank_accounts.bank_id = banks.id').
    group('banks.id, bank_accounts.bank_id').order('total DESC')
  }

  def self.to_collection
    order_popular.map do |bank|
      [bank.to_s, bank.id]
    end
  end

  def to_s
    [code, name].join(' . ')
  end
end
