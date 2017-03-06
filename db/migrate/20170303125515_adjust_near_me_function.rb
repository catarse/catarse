class AdjustNearMeFunction < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION near_me("1".projects) RETURNS boolean
    LANGUAGE sql STABLE
    AS $_$
    SELECT
      COALESCE($1.state_acronym, (SELECT u.address_state FROM users u WHERE u.id = $1.project_user_id)) = (SELECT u.address_state FROM users u WHERE u.id = current_user_id());
$_$;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION near_me("1".projects) RETURNS boolean
    LANGUAGE sql STABLE
    AS $_$
    SELECT
      COALESCE($1.state_acronym, (SELECT pa.address_state FROM project_accounts pa WHERE pa.project_id = $1.project_id)) = (SELECT u.address_state FROM users u WHERE u.id = current_user_id());
$_$;
}
  end
end
