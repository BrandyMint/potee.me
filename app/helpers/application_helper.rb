module ApplicationHelper
  def image_url image
    'http://' << Settings.application.host << image_path(image)
  end
end
