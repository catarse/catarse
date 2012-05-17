CATARSE.loader.dependencies = ["app/views/projects/embed"]
CATARSE_LOADER.load(CATARSE.loader.dependencies, 'dependencies')

$script.ready('dependencies', function() {
  CATARSE.ProjectsVideo_embedView = CATARSE.ProjectsEmbedView.extend({
  })
})
