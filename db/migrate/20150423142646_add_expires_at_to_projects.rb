class AddExpiresAtToProjects < ActiveRecord::Migration
  def change
    execute "
    DROP VIEW IF EXISTS user_feeds;
    DROP VIEW IF EXISTS financial_reports;
    DROP VIEW IF EXISTS projects_for_home;
    DROP VIEW IF EXISTS project_financials;
    DROP FUNCTION expires_at(projects);
             "
    add_column :projects, :expires_at, :timestamp
    execute " CREATE OR REPLACE VIEW financial_reports AS 
      SELECT p.name,
    u.moip_login,
    p.goal,
    p.expires_at,
    p.state
   FROM projects p
     JOIN users u ON u.id = p.user_id;"

     execute <<-SQL
    CREATE ORREPLACe VIEW user_feeds AS
       SELECT events.user_id,
      events.title,
      events.event_type,
      events.event_date,
      events.from_type,
      events.from_id,
      events.to_type,
      events.to_id,
      age(events.event_date) AS age
     FROM ( SELECT u.id AS user_id,
              p.name AS title,
              'new_project_on_category'::text AS event_type,
              p.online_date AS event_date,
              'CategoryFollower'::text AS from_type,
              cf.id AS from_id,
              'Project'::text AS to_type,
              p.id AS to_id
             FROM users u
               JOIN category_followers cf ON cf.user_id = u.id
               JOIN projects p ON p.category_id = cf.category_id
            WHERE p.state::text = ANY (ARRAY['online'::character varying::text, 'failed'::character varying::text, 'successful'::character varying::text, 'waiting_funds'::character varying::text])
          UNION ALL
           SELECT c.user_id,
              post.title,
              'project_posts'::text AS event_type,
              post.created_at AS event_date,
              'Project'::text AS from_type,
              post.project_id AS from_id,
              'ProjectPost'::text AS to_type,
              post.id AS to_id
             FROM ( SELECT DISTINCT contributions.user_id,
                      contributions.project_id
                     FROM contributions
                    WHERE contributions.state::text = ANY (ARRAY['confirmed'::character varying::text, 'refunded'::character varying::text, 'requested_refund'::character varying::text])) c
               JOIN project_posts post ON post.project_id = c.project_id
          UNION ALL
           SELECT c.user_id,
              p.name AS title,
              'contributed_project_finished'::text AS event_type,
              expires_at(p.*) AS event_date,
              'Contribution'::text AS from_type,
              ( SELECT contributions.id
                     FROM contributions
                    WHERE (contributions.state::text = ANY (ARRAY['confirmed'::character varying::text, 'refunded'::character varying::text, 'requested_refund'::character varying::text])) AND contributions.user_id = c.user_id AND contributions.project_id = c.project_id
                   LIMIT 1) AS from_id,
              'Project'::text AS to_type,
              p.id AS to_id
             FROM ( SELECT DISTINCT contributions.user_id,
                      contributions.project_id
                     FROM contributions
                    WHERE contributions.state::text = ANY (ARRAY['confirmed'::character varying::text, 'refunded'::character varying::text, 'requested_refund'::character varying::text])) c
               JOIN projects p ON p.id = c.project_id
            WHERE p.state::text = ANY (ARRAY['successful'::character varying::text, 'failed'::character varying::text])
          UNION ALL
           SELECT DISTINCT c.user_id,
              p2.name AS title,
              'new_project_from_common_owner'::text AS event_type,
              p2.online_date AS event_date,
              'User'::text AS from_type,
              p2.user_id AS from_id,
              'Project'::text AS to_type,
              p2.id AS to_id
             FROM ( SELECT DISTINCT contributions.user_id,
                      contributions.project_id
                     FROM contributions
                    WHERE contributions.state::text = ANY (ARRAY['confirmed'::character varying::text, 'refunded'::character varying::text, 'requested_refund'::character varying::text])) c
               JOIN projects p ON p.id = c.project_id
               JOIN projects p2 ON p2.user_id = p.user_id
            WHERE p2.id <> p.id AND (p.state::text = ANY (ARRAY['online'::character varying::text, 'waiting_funds'::character varying::text, 'failed'::character varying::text, 'successful'::character varying::text])) AND (p2.state::text = ANY (ARRAY['online'::character varying::text, 'waiting_funds'::character varying::text, 'failed'::character varying::text, 'successful'::character varying::text]))) events
    ORDER BY age(events.event_date);
     SQL

     execute <<-SQL
      CREATE VIEW projects_for_home AS
    WITH recommended_projects AS (SELECT 'recommended'::text AS origin, recommends.id, recommends.name, recommends.user_id, recommends.category_id, recommends.goal,  recommends.headline, recommends.video_url, recommends.short_url, recommends.created_at, recommends.updated_at, recommends.about_html, recommends.recommended, recommends.home_page_comment, recommends.permalink, recommends.video_thumbnail, recommends.state, recommends.online_days, recommends.online_date, recommends.traffic_sources, recommends.more_links, recommends.first_contributions AS first_backers, recommends.uploaded_image, recommends.video_embed_url FROM projects recommends WHERE (recommends.recommended AND ((recommends.state)::text = 'online'::text)) ORDER BY random() LIMIT 3), recents_projects AS (SELECT 'recents'::text AS origin, recents.id, recents.name, recents.user_id, recents.category_id, recents.goal, recents.headline, recents.video_url, recents.short_url, recents.created_at, recents.updated_at, recents.about_html, recents.recommended, recents.home_page_comment, recents.permalink, recents.video_thumbnail, recents.state, recents.online_days, recents.online_date, recents.traffic_sources, recents.more_links, recents.first_contributions AS first_backers, recents.uploaded_image, recents.video_embed_url FROM projects recents WHERE ((((recents.state)::text = 'online'::text) AND ((now() - recents.online_date) <= '5 days'::interval)) AND (NOT (recents.id IN (SELECT recommends.id FROM recommended_projects recommends)))) ORDER BY random() LIMIT 3), expiring_projects AS (SELECT 'expiring'::text AS origin, expiring.id, expiring.name, expiring.user_id, expiring.category_id, expiring.goal, expiring.headline, expiring.video_url, expiring.short_url, expiring.created_at, expiring.updated_at, expiring.about_html, expiring.recommended, expiring.home_page_comment, expiring.permalink, expiring.video_thumbnail, expiring.state, expiring.online_days, expiring.online_date, expiring.traffic_sources, expiring.more_links, expiring.first_contributions AS first_backers, expiring.uploaded_image, expiring.video_embed_url FROM projects expiring WHERE ((((expiring.state)::text = 'online'::text) AND (expiring.expires_at <= (now() + '14 days'::interval))) AND (NOT (expiring.id IN (SELECT recommends.id FROM recommended_projects recommends UNION SELECT recents.id FROM recents_projects recents)))) ORDER BY random() LIMIT 3) (SELECT recommended_projects.origin, recommended_projects.id, recommended_projects.name, recommended_projects.user_id, recommended_projects.category_id, recommended_projects.goal,  recommended_projects.headline, recommended_projects.video_url, recommended_projects.short_url, recommended_projects.created_at, recommended_projects.updated_at, recommended_projects.about_html, recommended_projects.recommended, recommended_projects.home_page_comment, recommended_projects.permalink, recommended_projects.video_thumbnail, recommended_projects.state, recommended_projects.online_days, recommended_projects.online_date, recommended_projects.traffic_sources, recommended_projects.more_links, recommended_projects.first_backers, recommended_projects.uploaded_image, recommended_projects.video_embed_url FROM recommended_projects UNION SELECT recents_projects.origin, recents_projects.id, recents_projects.name, recents_projects.user_id, recents_projects.category_id, recents_projects.goal,  recents_projects.headline, recents_projects.video_url, recents_projects.short_url, recents_projects.created_at, recents_projects.updated_at, recents_projects.about_html, recents_projects.recommended, recents_projects.home_page_comment, recents_projects.permalink, recents_projects.video_thumbnail, recents_projects.state, recents_projects.online_days, recents_projects.online_date, recents_projects.traffic_sources, recents_projects.more_links, recents_projects.first_backers, recents_projects.uploaded_image, recents_projects.video_embed_url FROM recents_projects) UNION SELECT expiring_projects.origin, expiring_projects.id, expiring_projects.name, expiring_projects.user_id, expiring_projects.category_id, expiring_projects.goal, expiring_projects.headline, expiring_projects.video_url, expiring_projects.short_url, expiring_projects.created_at, expiring_projects.updated_at, expiring_projects.about_html, expiring_projects.recommended, expiring_projects.home_page_comment, expiring_projects.permalink, expiring_projects.video_thumbnail, expiring_projects.state, expiring_projects.online_days, expiring_projects.online_date, expiring_projects.traffic_sources, expiring_projects.more_links, expiring_projects.first_backers, expiring_projects.uploaded_image, expiring_projects.video_embed_url FROM expiring_projects;
    SQL
  end
end
