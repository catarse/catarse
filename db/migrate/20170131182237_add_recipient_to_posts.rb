class AddRecipientToPosts < ActiveRecord::Migration
  def change
    add_column :project_posts, :recipients, :string, index: true
    execute "update project_posts set recipients = 'public' where exclusive = 'f';"
    execute "update project_posts set recipients = 'backers' where exclusive = 't';"
    execute <<-SQL
      create or replace view "1".project_posts_details as
        select
          pp.id,
          pp.project_id,
          public.is_owner_or_admin(p.user_id) as is_owner_or_admin,
          pp.exclusive,
          pp.title,
          (
            case
            when not pp.exclusive then pp.comment_html
            when pp.exclusive and (public.is_owner_or_admin(p.user_id) or public.current_user_has_contributed_to_project(p.id)) then pp.comment_html
            else null end
          ) as comment_html,
          pp.created_at,
          delivered_count(pp.*) as delivered_count,
          open_count(pp.*) as open_count,
          recipients,
          reward_id
        from project_posts pp
        join projects p on p.id = pp.project_id;

    SQL
  end
end
