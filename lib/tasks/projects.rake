namespace :projects do
  desc 'reject projects'
  task process_cancelation_requests: :environment do
    ProjectCancelation.find_each do |pc|
      if (pc.created_at + 24.hours) > DateTime.now && pc.project.can_cancel?
        pc.project.reject
      end
    end
  end
end
