begin
  Mailee::Config.site = Configuration.find_by_name('mailee').value
rescue
  Mailee::Config.site = nil
end
