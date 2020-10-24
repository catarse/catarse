class UserAdminRole < ApplicationRecord
  belongs_to :user

  validates :user, :role_label, presence: true
end
