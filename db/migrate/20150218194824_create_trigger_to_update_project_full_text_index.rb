class CreateTriggerToUpdateProjectFullTextIndex < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE FUNCTION update_full_text_index() RETURNS trigger AS $$
    BEGIN
      new.full_text_index :=  setweight(to_tsvector('portuguese', unaccent(coalesce(NEW.name::text, ''))), 'A') || 
                              setweight(to_tsvector('portuguese', unaccent(coalesce(NEW.permalink::text, ''))), 'C') || 
                              setweight(to_tsvector('portuguese', unaccent(coalesce(NEW.headline::text, ''))), 'B');
      new.full_text_index :=  new.full_text_index || setweight(to_tsvector('portuguese', unaccent(coalesce((SELECT c.name_pt FROM categories c WHERE c.id = NEW.category_id)::text, ''))), 'B');
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

    CREATE TRIGGER update_full_text_index 
    BEFORE INSERT OR UPDATE OF name, permalink, headline
    ON projects
    FOR EACH ROW
    EXECUTE PROCEDURE update_full_text_index();
    SQL
  end

  def down
    execute "DROP FUNCTION update_full_text_index() CASCADE;"
  end
end
