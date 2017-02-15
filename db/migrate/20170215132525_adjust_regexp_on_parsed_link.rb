class AdjustRegexpOnParsedLink < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION public.fb_parsed_link("user" users)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$select
CASE WHEN
	$1.facebook_link is not null
	and $1.facebook_link<>''
	and $1.facebook_link !~'[ @]'
	and $1.facebook_link ~* '^https?://[^/]*((facebook|fb).com|fb.me)(.br)?/[wd]' 
	and $1.facebook_link !~ '/search/|/media/set|/settings'
	and ($1.facebook_link !~ '/profile.php' or $1.facebook_link ~ '[?&]id=d+')
THEN
	CASE WHEN $1.facebook_link~'profile.php.*[?&]id=d+' THEN
            regexp_replace($1.facebook_link, '.*/profile.php.*[?&]id=(d+)([^d]+.*|$)','')
        ELSE
            regexp_replace(regexp_replace(regexp_replace(regexp_replace($1.facebook_link,'/?(\?.*)?$',''),'.*https?://[^/]*/',''),'(/(about|photos|friends|timeline|info|home|photos_stream|photos_albums|media_set|fref=ts)|#.*)$',''),'^pages/[^/]+/','pages/')
        END
ELSE
  null
END$function$;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION public.fb_parsed_link("user" users)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$select
CASE WHEN
	$1.facebook_link is not null
	and $1.facebook_link<>''
	and $1.facebook_link !~'[ @]'
	and $1.facebook_link ~* '^https?://[^/]*((facebook|fb).com|fb.me)(.br)?/[wd]' 
	and $1.facebook_link !~ '/search/|/media/set|/settings'
	and ($1.facebook_link !~ '/profile.php' or $1.facebook_link ~ '[?&]id=d+')
THEN
	CASE WHEN $1.facebook_link~'profile.php.*[?&]id=d+' THEN
            regexp_replace($1.facebook_link, '.*/profile.php.*[?&]id=(d+)([^d]+.*|$)','')
        ELSE
            regexp_replace(regexp_replace(regexp_replace(regexp_replace($1.facebook_link,'/?(?.*)?$',''),'.*https?://[^/]*/',''),'(/(about|photos|friends|timeline|info|home|photos_stream|photos_albums|media_set|fref=ts)|#.*)$',''),'^pages/[^/]+/','pages/')
        END
ELSE
  null
END$function$;
}
  end
end
