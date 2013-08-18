class ProjectsForHome < Project
  self.table_name = 'projects_for_home'

  scope :recommends, -> { where(origin: 'recommended') }
  scope :recents, -> { where(origin: 'recents') }
  scope :expiring, -> { where(origin: 'expiring') }
end
