class AdjustContributorsToRejected < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE VIEW "1"."contributors" AS 
 SELECT u.id,
    u.id AS user_id,
    c.project_id,
    json_build_object('profile_img_thumbnail', thumbnail_image(u.*), 'public_name', u.public_name, 'name', u.name, 'city', add.address_city, 'state', st.acronym, 'total_contributed_projects', ut.total_contributed_projects, 'total_published_projects', ut.total_published_projects) AS data,
    (EXISTS ( SELECT true AS bool
           FROM user_follows uf
          WHERE ((uf.user_id = current_user_id()) AND (uf.follow_id = u.id)))) AS is_follow
   FROM (((((contributions c
     JOIN users u ON ((u.id = c.user_id)))
     LEFT JOIN addresses add ON ((add.id = u.address_id)))
     LEFT JOIN states st ON ((st.id = add.state_id)))
     JOIN projects p ON ((p.id = c.project_id)))
     JOIN "1".user_totals ut ON ((ut.user_id = u.id)))
  WHERE ((
        CASE
            WHEN ((p.state)::text in('failed', 'rejected')) THEN was_confirmed(c.*)
            ELSE is_confirmed(c.*)
        END AND (NOT c.anonymous)) AND (u.deactivated_at IS NULL))
  GROUP BY u.id, c.project_id, ut.total_contributed_projects, ut.total_published_projects, add.address_city, st.acronym;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE VIEW "1"."contributors" AS 
 SELECT u.id,
    u.id AS user_id,
    c.project_id,
    json_build_object('profile_img_thumbnail', thumbnail_image(u.*), 'public_name', u.public_name, 'name', u.name, 'city', add.address_city, 'state', st.acronym, 'total_contributed_projects', ut.total_contributed_projects, 'total_published_projects', ut.total_published_projects) AS data,
    (EXISTS ( SELECT true AS bool
           FROM user_follows uf
          WHERE ((uf.user_id = current_user_id()) AND (uf.follow_id = u.id)))) AS is_follow
   FROM (((((contributions c
     JOIN users u ON ((u.id = c.user_id)))
     LEFT JOIN addresses add ON ((add.id = u.address_id)))
     LEFT JOIN states st ON ((st.id = add.state_id)))
     JOIN projects p ON ((p.id = c.project_id)))
     JOIN "1".user_totals ut ON ((ut.user_id = u.id)))
  WHERE ((
        CASE
            WHEN ((p.state)::text = 'failed'::text) THEN was_confirmed(c.*)
            ELSE is_confirmed(c.*)
        END AND (NOT c.anonymous)) AND (u.deactivated_at IS NULL))
  GROUP BY u.id, c.project_id, ut.total_contributed_projects, ut.total_published_projects, add.address_city, st.acronym;
}
  end
end
