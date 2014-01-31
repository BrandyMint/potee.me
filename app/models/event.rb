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
    self.title = self.title[0..254]
  end

  validates :date, presence: true
  validates :time, presence: true
  validates :project, presence: true

end
