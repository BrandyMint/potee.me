# -*- coding: utf-8 -*-
class Event < ActiveRecord::Base
  # FIX
  attr_protected :secret
  # attr_accessible :title, :date, :time, :project_id
  #
  default_scope order('date').order('time')

  belongs_to :project

  before_validation do
    self.title ||= 'Some event'
  end

  validates :date, presence: true
  validates :time, presence: true
end
