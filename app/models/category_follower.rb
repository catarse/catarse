# frozen_string_literal: true

class CategoryFollower < ApplicationRecord
  belongs_to :category
  belongs_to :user

  validates :category, uniqueness: { scope: :user }
end
