# encoding: utf-8
class RedactorRailsDocumentUploader < CarrierWave::Uploader::Base
  include RedactorRails::Backend::CarrierWave

  # storage :fog
  storage :file

  def store_dir
    "system/redactor_assets/documents/#{model.id}"
  end

  def extension_white_list
    RedactorRails.document_file_types
  end
end
