#
# FlexibleHandler module
# this module handles with flexible project
# methods, when is calling via project
#
module Project::FlexibleHandler
  extend ActiveSupport::Concern

  included do

    #
    # check if project is flexible.
    # project should be draft and have a flexible project
    # relation created.
    #
    # usage:
    #
    # project = Project.find
    # project.is_flexible?
    #
    def is_flexible?
      # TODO: maybe move this to handles on database function.
      self.flexible_project.present?
    end

  end
end
