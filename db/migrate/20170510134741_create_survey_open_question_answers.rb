class CreateSurveyOpenQuestionAnswers < ActiveRecord::Migration
  def change
    create_table :survey_open_question_answers do |t|
      t.references :survey_open_question, null: false
      t.references :contribution, null: false
      t.text :answer

      t.timestamps
    end
  end
end
