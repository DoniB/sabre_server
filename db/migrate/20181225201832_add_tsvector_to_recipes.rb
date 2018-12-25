class AddTsvectorToRecipes < ActiveRecord::Migration[5.2]
  def up
    add_column :recipes, :tsv, :tsvector
    add_index :recipes, :tsv, using: "gin"

    execute <<-SQL
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON recipes FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger(
        tsv, 'pg_catalog.portuguese', name, ingredients
      );
    SQL

    now = Time.current.to_s(:db)
    update("UPDATE recipes SET updated_at = '#{now}'")
  end

  def down
    execute <<-SQL
      DROP TRIGGER tsvectorupdate
      ON recipes
    SQL

    remove_index :recipes, :tsv
    remove_column :recipes, :tsv
  end
end
