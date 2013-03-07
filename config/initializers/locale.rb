# tell the I18n library where to find your translations
I18n.load_path += Dir[Rails.root.join('lib', 'locales', '*.{rb,yml}')]
I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

# set available locales from config/locales files
I18n.available_locales = Dir[Rails.root.join('config', 'locales', '*.{yml}')].collect {|l| locale = l.scan(/.+\/(..)\.yml/)[0]; locale[0].to_sym unless locale.nil?}.delete_if {|locale| locale.nil?}