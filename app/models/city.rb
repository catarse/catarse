# frozen_string_literal: true

class City < ActiveRecord::Base
  belongs_to :state

  def show_name
    "#{name}, #{state.acronym}"
  end
end
