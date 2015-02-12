class ProjectAccount < ActiveRecord::Base
  belongs_to :project
  belongs_to :bank
  belongs_to :user

  def decorator
    @decorator ||= ProjectAccountDecorator.new(self)
  end
end
