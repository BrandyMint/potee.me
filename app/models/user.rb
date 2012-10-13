class User < ActiveRecord::Base

  has_many :authentications

end
