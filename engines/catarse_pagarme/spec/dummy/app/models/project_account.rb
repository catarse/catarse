# -*- coding: utf-8 -*-
class ProjectAccount < ActiveRecord::Base
  belongs_to :project
  belongs_to :bank
end
