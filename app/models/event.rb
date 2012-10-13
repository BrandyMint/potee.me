class Event < ActiveRecord::Base
  attr_accessible :title, :date, :time

  belongs_to :project

  validates_presence_of :date, :time
end
