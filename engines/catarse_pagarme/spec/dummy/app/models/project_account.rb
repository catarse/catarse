# -*- coding: utf-8 -*-
# frozen_string_literal: true

class ProjectAccount < ActiveRecord::Base
  belongs_to :project
  belongs_to :bank
end
