class CreateSurveyMultipleChoiceQuestions < ActiveRecord::Migration
  def change
    create_table :survey_multiple_choice_questions do |t|
      t.references :survey, null: false
      t.text :question
      t.text :description

      t.timestamps
    end
  end
end
