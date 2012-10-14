class User < ActiveRecord::Base
  attr_protected :secret

  has_many :authentications
  has_many :projects

  def to_s
    name || email
  end

  def incognito?
    authentications.empty?
  end

end
