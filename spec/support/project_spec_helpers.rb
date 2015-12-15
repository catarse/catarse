 module ProjectSpecHelpers
   # helper to handle with project creation with transitions
   def create_project(project_attr, transition_attr)
     project = FactoryGirl.create(:project, project_attr)
     project.project_transitions.destroy_all
     if transition_attr.present?
       if transition_attr.kind_of?(Array)
         transition_attr.each do |t_attr| 
           FactoryGirl.create(:project_transition,
             t_attr.merge!(project: project))
         end
       else
         FactoryGirl.create(:project_transition,
           transition_attr.merge!(project: project))
       end
     end
     project.update_expires_at
     project.save
     project.reload
   end

   # helper to handle with project creation with transitions
   def create_flexible_project(project_attr, flex_att, transition_attr)
   end
 end

 RSpec.configure do |config|
   config.include ProjectSpecHelpers
 end
