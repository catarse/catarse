# frozen_string_literal: true

class ProjectFinancial < ActiveRecord::Base
  acts_as_copy_target
end
