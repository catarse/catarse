class AdjustUserFeed < ActiveRecord::Migration
  def up
    execute <<-SQL
      drop view user_feeds;
      create or replace view user_feeds as
      SELECT events.*, age(events.event_date) AS age FROM
      ((
      -- new projects on categories that I follow
        select
          u.id as user_id,
          p.name as title,
          'new_project_on_category' as event_type,
          p.online_date as event_date,
          'CategoryFollower' as from_type,
          cf.id as from_id,
          'Project' as to_type,
          p.id as to_id
        from users u
        inner join category_followers cf on cf.user_id = u.id
        inner join projects p on p.category_id = cf.category_id
        where p.state in ('online', 'failed', 'successful', 'waiting_funds')
      )
      UNION ALL
      (
      -- Posts of projcts that i've backed
        select
          c.user_id as user_id,
          post.title as title,
          'project_posts' as event_type,
          post.created_at as event_date,
          'Project' as from_type,
          post.project_id as from_id,
          'ProjectPost' as to_type,
          post.id as to_id
        from (select DISTINCT user_id, project_id from contributions where state in ('confirmed', 'refunded', 'requested_refund')) c
        inner join project_posts post on post.project_id = c.project_id
       )
       UNION ALL
      (
      -- finished projects that i've contributed
        select
          c.user_id as user_id,
          p.name as title,
          'contributed_project_finished' as event_type,
          p.expires_at as event_date,
          'Contribution' as from_type,
          (
            select id from contributions
            where state in ('confirmed', 'refunded', 'requested_refund')
            and user_id = c.user_id and project_id = c.project_id
            limit 1
          ) as from_id,
          'Project' as to_type,
          p.id as to_id
        from (select DISTINCT user_id, project_id from contributions where state in ('confirmed', 'refunded', 'requested_refund')) c
        inner join projects p on p.id = c.project_id
        where p.state in ('successful', 'failed')
       )
       UNION ALL
      (
      -- new projects from owner of projects that i've contributed
        select
          DISTINCT
            c.user_id as user_id,
            p2.name as title,
            'new_project_from_common_owner' as event_type,
            p2.online_date as event_date,
            'User' as from_type,
            p2.user_id as from_id,
            'Project' as to_type,
            p2.id as to_id
        from (
          select DISTINCT user_id, project_id from contributions where state in ('confirmed', 'refunded', 'requested_refund')
        ) c
        join projects p on p.id = c.project_id
        join projects p2 on p2.user_id = p.user_id
        where p2.id <> p.id
        and p.state in ('online', 'waiting_funds', 'failed', 'successful')
        and p2.state in ('online', 'waiting_funds', 'failed', 'successful')
       )
       )
       events
       ORDER BY age
    SQL
  end

  def down
    execute <<-SQL
drop view user_feeds;
      create or replace view user_feeds as
SELECT events.*, age(events.event_date) AS age FROM
((
-- new projects on categories that I follow
  select
    u.id as user_id,
    p.name as title,
    'new_project_on_category' as event_type,
    p.online_date as event_date,
    'CategoryFollower' as from_type,
    cf.id as from_id,
    'Project' as to_type,
    p.id as to_id,
    null as common_type,
    null as common_id
  from users u
  inner join category_followers cf on cf.user_id = u.id
  inner join projects p on p.category_id = cf.category_id
  where p.state in ('online', 'failed', 'successful', 'waiting_funds')
)
UNION ALL
(
-- Posts of projcts that i've backed
  select
    c.user_id as user_id,
    post.title as title,
    'project_posts' as event_type,
    post.created_at as event_date,
    'Project' as from_type,
    post.project_id as from_id,
    'ProjectPost' as to_type,
    post.id as to_id,
    'Contribution' as common_type,
    (
      select id from contributions
      where state in ('confirmed', 'refunded', 'requested_refund')
      and user_id = c.user_id and project_id = c.project_id
      limit 1
    ) as common_id
  from (select DISTINCT user_id, project_id from contributions where state in ('confirmed', 'refunded', 'requested_refund')) c
  inner join project_posts post on post.project_id = c.project_id
 )
 UNION ALL
(
-- finished projects that i've contributed
  select
    c.user_id as user_id,
    p.name as title,
    'contributed_project_finished' as event_type,
    p.expires_at as event_date,
    null as common_type,
    null as common_id,
    'Project' as to_type,
    p.id as to_id,
    'Contribution' as from_type,
    (
      select id from contributions
      where state in ('confirmed', 'refunded', 'requested_refund')
      and user_id = c.user_id and project_id = c.project_id
      limit 1
    ) as from_id
  from (select DISTINCT user_id, project_id from contributions where state in ('confirmed', 'refunded', 'requested_refund')) c
  inner join projects p on p.id = c.project_id
  where p.state in ('successful', 'failed')
 )
 UNION ALL
(
-- new projects from owner of projects that i've contributed
  select
    c.user_id as user_id,
    p2.name as title,
    'new_project_from_common_owner' as event_type,
    p2.online_date as event_date,
    'User' as from_type,
    p2.user_id as from_id,
    'Project' as to_type,
    p2.id as to_id,
    'Contribution' as common_type,
    (
      select id from contributions
      where state in ('confirmed', 'refunded', 'requested_refund')
      and user_id = c.user_id and project_id = c.project_id
      limit 1
    ) as common_id
  from (
    select DISTINCT user_id, project_id from contributions where state in ('confirmed', 'refunded', 'requested_refund')
  ) c
  join projects p on p.id = c.project_id
  join projects p2 on p2.user_id = p.user_id
  where p2.id <> p.id
  and p.state in ('online', 'waiting_funds', 'failed', 'successful')
  and p2.state in ('online', 'waiting_funds', 'failed', 'successful')
 )
 )
 events
 ORDER BY age
    SQL
  end
end
