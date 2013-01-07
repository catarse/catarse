namespace :catarse do
  namespace :config do
    desc "Load default configuration values into DB"
    task :load_defaults => :environment do
      settings = YAML.load_file("#{Rails.root}/config/default_app_config.yml")
      settings.each do |setting|
        Configuration[setting[0]] = setting[1]
      end
    end
  end
end