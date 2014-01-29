# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  storage :file

  version :thumb do
    process resize_to_fill: [24, 24]
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
     %w(jpg jpeg gif png)
  end

end
