class ProjectObserver < ActiveRecord::Observer
  observe :project

  def notify_backers(project)
    project.backers.confirmed.each do |backer|
      unless backer.can_refund or backer.notified_finish
        if project.successful?
          Notification.notify_backer_project_successful(backer, :backer_project_successful)
          if backer.reward
            #TODO
          end
        else
          Notification.notify_backer_project_unsuccessful(backer, :backer_project_unsuccessful)
        end
        backer.update_attributes({ notified_finish: true })
      end
    end
    project.update_attributes finished: true, successful: project.successful?
  end

end
