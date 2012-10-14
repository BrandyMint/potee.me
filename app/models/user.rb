class User < ActiveRecord::Base
  has_many :authentications

  def to_s
    name || email
  end

end
