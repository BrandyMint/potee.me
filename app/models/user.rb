class User < ActiveRecord::Base
  attr_protected :secret

  scope :without_authentications, where('id not in (select user_id from authentications)')

  has_many :authentications, :dependent => :destroy
  has_many :projects, :dependent => :destroy
  has_one  :dashboard, :dependent => :destroy

  mount_uploader :avatar, AvatarUploader

  after_create :create_dashboard

  def self.destroy_orphans
    without_authentications.where('created_at<?', 14.days.ago).destroy_all
  end

  def to_s
    name || email
  end

  def incognito?
    authentications.empty?
  end

  private

  def create_dashboard
    Dashboard.create(user: self, current_date: Time.now)
  end

end
