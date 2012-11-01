class RecreateAvatar < ActiveRecord::Migration
  def up
    User.all.each do |user|
      user.avatar.recreate_versions! if user.avatar.present?
    end
  end

  def down
  end
end
