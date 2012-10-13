class Authentication < ActiveRecord::Base

  validates_presence_of :provider, :uid

  belongs_to :user

  def self.authenticate_or_create(auth)
    where(auth.slice('provider', 'uid')).first || create_user_with_authentication(auth)
  end

  def self.create_user_with_authentication(auth)
    user = User.create do |user|
      user.email = auth['info']['email']
      user.name = auth['info']['name']
    end

    user.authentications.create do |authentication|
      authentication.provider = auth['provider']
      authentication.uid = auth['uid']
    end

    user
  end

end
