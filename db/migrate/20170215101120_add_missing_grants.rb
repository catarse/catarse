class AddMissingGrants < ActiveRecord::Migration
  def change
    execute %Q{
grant select on sendgrid_events to anonymous;
grant select on project_post_notifications to anonymous;
grant select on project_posts to anonymous;
}
  end
end
