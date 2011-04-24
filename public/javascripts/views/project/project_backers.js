var ProjectBackersView = ProjectPaginatedContentView.extend({
  modelView: BackerView,
  // TODO internationalize
  emptyText: "Ninguém apoiou este projeto ainda. Que tal ser o primeiro?"
})