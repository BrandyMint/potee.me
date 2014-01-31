# -*- coding: utf-8 -*-
class Project < ActiveRecord::Base
  # attr_accessible :title, :started_at, :finish_at, :color_index
  # FIX
  attr_protected :secret

  # default_scope order :started_at

  belongs_to :owner, class_name: 'User'
  has_many :events, dependent: :destroy
  has_many :project_connections, dependent: :destroy

  before_validation do
    self.started_at ||= Date.today()
    self.finish_at ||= self.started_at + 1.months
    self.title = self.title[0..254] unless self.title.blank?
  end

  validates :title, presence: true
  validates :started_at, presence: true
  validates :owner_id, presence: true

end
