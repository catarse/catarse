class CopyProjectPostRewardIdToPostRewardTable < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL

    insert into post_rewards (project_post_id, reward_id, created_at, updated_at)
    select id as project_post_id, reward_id, created_at, updated_at
    from project_posts
    where recipients = 'reward' and reward_id <> 0;

    update project_posts set recipients = 'rewards' where recipients = 'reward';

    SQL
  end

  def down
    execute <<-SQL

    insert into project_posts(user_id, project_id, title, comment_html, created_at, updated_at, exclusive, reward_id, recipients, common_id)
    select pp.user_id, pp.project_id, pp.title, pp.comment_html, pp.created_at, pp.updated_at, pp.exclusive, pr.reward_id, pp.recipients, pp.common_id
    from project_posts pp
    join post_rewards pr on pp.id = pr.project_post_id;

    delete from post_rewards;

    update project_posts set recipients = 'reward' where recipients = 'rewards';
    SQL
  end
end
