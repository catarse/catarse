class CreateSurveyMultipleChoiceQuestionAnswers < ActiveRecord::Migration
  def change
    create_table :survey_multiple_choice_question_answers do |t|
      t.references :survey_multiple_choice_question, null: false
      t.references :survey_question_choice, null: false
      t.references :contribution, null: false

      t.timestamps
    end
  end
end
