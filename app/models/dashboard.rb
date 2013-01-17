class Dashboard < ActiveRecord::Base
  attr_protected :secret

  belongs_to :user

end