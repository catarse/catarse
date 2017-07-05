class AdjustFullTextIndexOnProjects < ActiveRecord::Migration
  def change
    execute %Q{
CREATE OR REPLACE FUNCTION public.generate_project_full_text_index(project projects)
 RETURNS tsvector
 LANGUAGE plpgsql
 STABLE
AS $function$
        DECLARE
            full_text_index tsvector;
        BEGIN

            full_text_index :=  setweight(to_tsvector('portuguese', unaccent(coalesce(project.name::text, ''))), 'A') || 
                                setweight(to_tsvector('portuguese', unaccent(coalesce(project.permalink::text, ''))), 'C') || 
                                setweight(to_tsvector('portuguese', unaccent(coalesce(project.headline::text, ''))), 'B') || 
                                setweight(to_tsvector('portuguese', unaccent(coalesce((SELECT c.name_pt FROM categories c WHERE c.id = project.category_id)::text, ''))), 'B') || 
                                setweight(to_tsvector('portuguese', unaccent(coalesce((select array_agg(t.name)::text from public.taggings ta join public_tags t on t.id = ta.public_tag_id where ta.project_id = project.id)::text, ''))), 'B') || 
                                setweight(to_tsvector('portuguese', unaccent(coalesce((SELECT u.public_name FROM users u WHERE u.id = project.user_id)::text, ''))), 'C');

          RETURN full_text_index;
        END
    $function$

}
  end
end
