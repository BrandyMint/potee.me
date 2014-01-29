ActiveAdmin.register ProjectConnection do

  controller do
    def scoped_collection
      resource_class.includes(:user).includes(:project)
    end
  end

  index do 
    column :user
    column :project
    column :position
    actions
  end

end
