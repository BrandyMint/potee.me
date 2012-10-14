# -*- coding: utf-8 -*-
class Event < ActiveRecord::Base
  # FIX
  attr_protected :secret
  # attr_accessible :title, :date, :time, :project_id

  belongs_to :project

  before_validation do
    self.title ||= 'Событие'
  end

  validates_presence_of :date, :time
end
