# coding: utf-8
require 'rails_helper'

RSpec.describe FlexibleProjectTransition, type: :model do
  describe "associations" do
    it{ is_expected.to belong_to :flexible_project }
  end
end
