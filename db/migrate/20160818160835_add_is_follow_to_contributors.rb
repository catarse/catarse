class AddIsFollowToContributors < ActiveRecord::Migration
  def change
    %Q{
        CREATE OR REPLACE VIEW "1".contributors AS 
        SELECT u.id,
            u.id AS user_id,
            c.project_id,
            json_build_object('profile_img_thumbnail', thumbnail_image(u.*), 'name', u.name, 'city', u.address_city, 'state', u.address_state, 'total_contributed_projects', ut.total_contributed_projects, 'total_published_projects', ut.total_published_projects ) AS data,
            exists(select true from user_follows uf where uf.user_id = current_user_id() and uf.follow_id = u.id) AS is_follow
           FROM contributions c
             JOIN users u ON u.id = c.user_id
             JOIN projects p ON p.id = c.project_id
             JOIN "1".user_totals ut ON ut.user_id = u.id
          WHERE
                CASE
                    WHEN p.state::text = 'failed'::text THEN was_confirmed(c.*)
                    ELSE is_confirmed(c.*)
                END AND NOT c.anonymous AND u.deactivated_at IS NULL
          GROUP BY u.id, c.project_id, ut.total_contributed_projects, ut.total_published_projects;


          GRANT SELECT ON "1".contributors TO admin, anonymous, web_user;
            }
  end
end
