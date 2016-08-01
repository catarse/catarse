class UpgradeProjectSearchIndex < ActiveRecord::Migration
  def up
    %Q{
CREATE OR REPLACE FUNCTION update_full_text_index() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      new.full_text_index :=  public.generate_project_full_text_index(NEW);
      RETURN NEW;
    END;
    $$;

CREATE OR REPLACE FUNCTION public.generate_project_full_text_index(project public.projects) RETURNS tsvector
LANGUAGE plpgsql
STABLE
AS $$
    DECLARE
        full_text_index tsvector;
    BEGIN

        full_text_index :=  setweight(to_tsvector('portuguese', unaccent(coalesce(project.name::text, ''))), 'A') || 
                            setweight(to_tsvector('portuguese', unaccent(coalesce(project.permalink::text, ''))), 'C') || 
                            setweight(to_tsvector('portuguese', unaccent(coalesce(project.headline::text, ''))), 'B') || 
                            setweight(to_tsvector('portuguese', unaccent(coalesce((SELECT c.name_pt FROM categories c WHERE c.id = project.category_id)::text, ''))), 'B') || 
                            setweight(to_tsvector('portuguese', unaccent(coalesce((select array_agg(t.name)::text from public.taggings ta join public_tags t on t.id = ta.public_tag_id where ta.project_id = project.id)::text, ''))), 'B') || 
                            setweight(to_tsvector('portuguese', unaccent(coalesce((SELECT u.name FROM users u WHERE u.id = project.user_id)::text, ''))), 'C');

      RETURN full_text_index;
    END
$$;

CREATE OR REPLACE FUNCTION update_project_full_text_index() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      UPDATE projects p
         SET full_text_index = public.generate_project_full_text_index(p)
         WHERE p.id = NEW.project_id;

      RETURN NEW;
    END;
    $$;


CREATE TRIGGER update_project_full_text_index BEFORE INSERT OR UPDATE OF public_tag_id ON public.taggings FOR EACH ROW EXECUTE PROCEDURE update_project_full_text_index();
    }
  end

  def down
    %Q{
CREATE OR REPLACE FUNCTION public.update_full_text_index() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      new.full_text_index :=  setweight(to_tsvector('portuguese', unaccent(coalesce(NEW.name::text, ''))), 'A') || 
                              setweight(to_tsvector('portuguese', unaccent(coalesce(NEW.permalink::text, ''))), 'C') || 
                              setweight(to_tsvector('portuguese', unaccent(coalesce(NEW.headline::text, ''))), 'B');
      new.full_text_index :=  new.full_text_index || setweight(to_tsvector('portuguese', unaccent(coalesce((SELECT c.name_pt FROM categories c WHERE c.id = NEW.category_id)::text, ''))), 'B');
      RETURN NEW;
    END;
    $$;


DROP FUNCTION update_project_full_text_index() CASCADE;
DROP FUNCTION public.generate_project_full_text_index(public.projects);
    }
  end
end
