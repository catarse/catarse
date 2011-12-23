CATARSE.loader.dependencies = ["app/views/static/base"]
CATARSE.loader.load(CATARSE.loader.dependencies, 'dependencies')

$script.ready('dependencies', function() {
  CATARSE.StaticFaqView = CATARSE.StaticBaseView.extend({
  })
})
