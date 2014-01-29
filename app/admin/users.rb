ActiveAdmin.register User do
  menu :parent => "Admin"

  index do
    column :avatar do |user|
      image_tag user.avatar.thumb.url, size: '24x24'
    end
    column :created_at
    column :last_sign_in_at
    column :name
    column :email
    column :connections do |user|
      link_to "Connections (#{user.projects.count})", admin_project_connections_url(q: {user_id_eq: user.id})
    end

    actions
  end

end
