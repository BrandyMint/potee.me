class User < ActiveRecord::Base
  attr_protected :secret

  has_many :authentications, :dependent => :destroy
  has_many :projects, :dependent => :destroy

  def to_s
    name || email
  end

  def incognito?
    authentications.empty?
  end

end
