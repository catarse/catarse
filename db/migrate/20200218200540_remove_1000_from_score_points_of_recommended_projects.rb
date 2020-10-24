class Remove1000FromScorePointsOfRecommendedProjects < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL

      update project_score_storages set score = public.score(p.*) from  project_score_storages pss inner join projects p on pss.project_id = p.id;

    SQL
  end
end
