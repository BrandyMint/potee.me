class User < ActiveRecord::Base
  has_many :authentications
  has_many :projects

  def to_s
    name || email
  end

end
