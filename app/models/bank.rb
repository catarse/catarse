class Bank < ActiveRecord::Base
  MOST_POPULAR_LIMIT = 10

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

  # Returns a array with then 10 more used banks by users
  # +current_bank+ is Bank object, that you can inject another bank to the list
  # this is need when user as a bank that is not listed on most popular
  def self.most_popular_collection(current_bank = nil)
    collection = order_popular.limit(MOST_POPULAR_LIMIT).map do |bank|
      [bank.to_s, bank.id]
    end

    if current_bank.present?
      collection << [current_bank.to_s, current_bank.id]
    end

    collection << [I18n.t('shared.no_bank_label'), 0]

    collection
  end

  def to_s
    [code, name].join(' . ')
  end
end
