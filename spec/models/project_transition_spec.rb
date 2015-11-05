# coding: utf-8
require 'rails_helper'

RSpec.describe ProjectTransition, type: :model do
  describe "associations" do
    it{ is_expected.to belong_to :project }
  end
end
