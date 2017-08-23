class MailMarketingUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :mail_marketing_list
end
