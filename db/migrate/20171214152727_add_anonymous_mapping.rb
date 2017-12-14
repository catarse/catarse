class AddAnonymousMapping < ActiveRecord::Migration
  def change
    if !Rails.env.test?
      execute <<-SQL
      CREATE USER MAPPING FOR anonymous
      SERVER common_db
      OPTIONS (user '#{CatarseSettings[:common_db_user]}', password '#{CatarseSettings[:common_db_password]}');

        CREATE USER MAPPING FOR admin
      SERVER common_db
      OPTIONS (user '#{CatarseSettings[:common_db_user]}', password '#{CatarseSettings[:common_db_password]}');

        CREATE USER MAPPING FOR web_user
      SERVER common_db
      OPTIONS (user '#{CatarseSettings[:common_db_user]}', password '#{CatarseSettings[:common_db_password]}');
      SQL
    end
  end
end
