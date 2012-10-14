class Event < ActiveRecord::Base
  attr_accessible :title, :date, :time, :project_id

  belongs_to :project

  validates_presence_of :date, :time
end
