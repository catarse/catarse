class MigrateOriginsFromReferrals < ActiveRecord::Migration
  def up
    execute " set statement_timeout to 0;"
    execute <<-SQL
insert into origins (referral, domain, created_at)
select r.ref, r.domain, min(r.created_at) from (SELECT
nullif((
case when (
    select replace(ts.token, 'www.', '')
    from ts_parse('default', p.referral_link) ts
    where ts.tokid = (SELECT tokid FROM ts_token_type('default') where alias = 'host')
) is null then p.referral_link else null end
), '') as ref,
coalesce((
    select replace(ts.token, 'www.', '')
    from ts_parse('default', p.referral_link) ts
    where ts.tokid = (SELECT tokid FROM ts_token_type('default') where alias = 'host')
), 'catarse.me') as domain,
min(p.created_at) as created_at
from projects p
where p.referral_link is not null
group by ref, domain
UNION
select
nullif((
case when (
    select replace(ts.token, 'www.', '')
    from ts_parse('default', p.referral_link) ts
    where ts.tokid = (SELECT tokid FROM ts_token_type('default') where alias = 'host')
) is null then p.referral_link else null end
), '') as ref,
coalesce((
    select replace(ts.token, 'www.', '')
    from ts_parse('default', p.referral_link) ts
    where ts.tokid = (SELECT tokid FROM ts_token_type('default') where alias = 'host')
), 'catarse.me') as domain,
min(p.created_at) as created_at
from contributions p
where p.referral_link is not null
group by ref, domain
) as r group by r.ref, r.domain;
    SQL
  end

  def down
    execute <<-SQL
DELETE FROM origins;
    SQL
  end
end
