# coding: utf-8

class Channels::ProjectsController < ProjectsController
  belongs_to :channel, finder: :find_by_permalink!, param: :profile_id

  after_filter only: [:create] { @project.channels << @channel }

end


