class AddedMissingGrantsToPosts < ActiveRecord::Migration
  def up
    execute %Q{
grant select on sendgrid_events to admin, web_user;
grant select on project_post_notifications to admin, web_user;
grant select on project_posts to admin, web_user;
}
  end

  def down
    execute %Q{
revoke select on sendgrid_events from admin, web_user;
revoke select on project_post_notifications from admin, web_user;
revoke select on project_posts from admin, web_user;
}
  end
end
