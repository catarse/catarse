# frozen_string_literal: true

class City < ApplicationRecord
  belongs_to :state

  def show_name
    "#{name}, #{state.acronym}"
  end
end
