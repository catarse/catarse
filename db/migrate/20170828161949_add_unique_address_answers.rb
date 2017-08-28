class AddUniqueAddressAnswers < ActiveRecord::Migration
  def change
    execute <<-SQL
    ALTER TABLE survey_address_answers ADD UNIQUE (contribution_id, address_id);
    ALTER TABLE survey_multiple_choice_question_answers ADD UNIQUE (contribution_id, survey_multiple_choice_question_id);
    ALTER TABLE survey_open_question_answers ADD UNIQUE (contribution_id, survey_open_question_id);
    SQL
  end
end
