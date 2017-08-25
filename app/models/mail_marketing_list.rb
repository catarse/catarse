class MailMarketingList < ActiveRecord::Base
  validates :provider, :label, :list_id, presence: true
  validates :provider,  uniqueness: {scope: :label }
  validates :provider,  uniqueness: {scope: :list_id }
end
