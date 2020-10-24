# frozen_string_literal: true

class Tagging < ApplicationRecord
  belongs_to :project
  belongs_to :tag, optional: true
  belongs_to :public_tag, optional: true
end
