class ProjectAccount < ActiveRecord::Base
  belongs_to :project
  belongs_to :bank
  belongs_to :user

  delegate   :display_bank_account, :display_bank_account_owner, :display_address, to: :decorator

  def decorator
    @decorator ||= ProjectAccountDecorator.new(self)
  end
end
