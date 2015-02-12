desc "Migrate project thumbnails to new format"
task :migrate_project_thumbnails => :environment do
  projects = Project.where('uploaded_image is not null').all

  projects.each do |project|
    begin
      project.uploaded_image.recreate_versions!(:project_thumb_large) if project.uploaded_image.file.present?
      puts "Recreating versions: #{project.id} - #{project.name}"
    rescue Exception
      puts "Original image not found"
    end
  end
end

