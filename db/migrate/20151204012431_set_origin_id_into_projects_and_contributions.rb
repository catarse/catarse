class SetOriginIdIntoProjectsAndContributions < ActiveRecord::Migration
  def up
    execute " set statement_timeout to 0;"
    execute <<-SQL
update projects p set origin_id = (
    select o.id
    from origins o
    where o.referral = p.referral_link
    or (o.domain = (
        select replace(ts.token, 'www.', '')
        from ts_parse('default', p.referral_link) ts
        where ts.tokid = (SELECT tokid FROM ts_token_type('default') where alias = 'host')
    ) and o.referral is null)
)
where p.referral_link is not null
and p.referral_link <> ''
and (
  video_thumbnail is not null
  or uploaded_image is not null);

update contributions c set origin_id = (
    select o.id
    from origins o
    where o.referral = c.referral_link
    or ( o.domain = (
        select replace(ts.token, 'www.', '')
        from ts_parse('default', c.referral_link) ts
        where ts.tokid = (SELECT tokid FROM ts_token_type('default') where alias = 'host')
    ) and o.referral is null)
)
where c.referral_link is not null
and c.referral_link <> '';
    SQL
  end

  def down
    execute " set statement_timeout to 0;"
    execute <<-SQL
update contributions set origin_id = null where origin_id is not null;
update projects set origin_id = null where origin_id is not null;
    SQL
  end
end
