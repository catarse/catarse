class AddRejectedToFunc < ActiveRecord::Migration
  def up
    execute <<-SQL
ALTER TABLE projects
    DROP COLUMN sent_to_analysis_at,
    DROP COLUMN rejected_at,
    DROP COLUMN online_date,
    DROP COLUMN referral_link,
    DROP COLUMN sent_to_draft_at;

CREATE FUNCTION rejected_at(project projects) RETURNS timestamp without time zone
    LANGUAGE sql STABLE
    AS $$
        SELECT get_date_from_project_transitions(project.id, 'rejected');
    $$;
    SQL
  end

  def down
    execute <<-SQL
DROP FUNCTION rejected_at(project projects);
ALTER TABLE projects
    ADD COLUMN referral_link text,
    ADD COLUMN sent_to_analysis_at timestamp without time zone,
    ADD COLUMN rejected_at timestamp without time zone,
    ADD COLUMN online_date timestamp without time zone,
    ADD COLUMN sent_to_draft_at timestamp without time zone;

UPDATE projects p
    SET referral_link = (
        SELECT COALESCE(o.referral, o.domain)
            FROM origins o
            WHERE o.id = p.origin_id ),
    online_date = p.online_at,
    sent_to_analysis_at = p.in_analysis_at,
    rejected_at = (
        SELECT pt.created_at
            FROM "1".project_transitions pt
            WHERE pt.project_id = p.id
                AND pt.state = 'rejected'),
    sent_to_draft_at = p.created_at,
    uploaded_image = (
        CASE WHEN video_thumbnail is not null THEN
            uploaded_image
        ELSE
            COALESCE(uploaded_image, 'missing_image')
        END),
    about_html = COALESCE(about_html, name),
    headline = COALESCE(headline, name);
    SQL
  end
end
