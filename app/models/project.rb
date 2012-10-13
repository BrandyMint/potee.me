# -*- coding: utf-8 -*-
class Project < ActiveRecord::Base
  # attr_accessible :title, :started_at, :finish_at, :color_index
  # FIX
  attr_protected :secret

  validates :title, :presence => true, :uniqueness => true
  validates :started_at, :presence => true
  validates :color_index, :presence => true
end
