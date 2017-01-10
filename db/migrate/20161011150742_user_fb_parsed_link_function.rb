class UserFbParsedLinkFunction < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION public.fb_parsed_link("user" users)
  RETURNS text AS
$BODY$select
CASE WHEN
	$1.facebook_link is not null
	and $1.facebook_link<>''
	and $1.facebook_link !~'[\s@]'
	and $1.facebook_link ~* '^https?://[^/]*((facebook|fb).com|fb.me)(\.br)?/[\w\d]' 
	and $1.facebook_link !~ '/search/|/media/set|/settings'
	and ($1.facebook_link !~ '/profile.php' or $1.facebook_link ~ '[\?\&]id=\d+')
THEN
	CASE WHEN $1.facebook_link~'profile\.php.*[\?\&]id=\d+' THEN
            regexp_replace($1.facebook_link, '.*/profile\.php.*[\?\&]id=(\d+)([^\d]+.*|$)','\1')
        ELSE
            regexp_replace(regexp_replace(regexp_replace(regexp_replace($1.facebook_link,'/?(\?.*)?$',''),'.*https?://[^/]*/',''),'(/(about|photos|friends|timeline|info|home|photos_stream|photos_albums|media_set|fref=ts)|#.*)$',''),'^pages/[^/]+/','pages/')
        END
ELSE
  null
END$BODY$
  LANGUAGE sql IMMUTABLE
    }
  end

  def down
    execute %Q{
      DROP FUNCTION public.fb_parsed_link;
    }
  end
end
