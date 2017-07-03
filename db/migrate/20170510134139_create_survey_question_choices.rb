class CreateSurveyQuestionChoices < ActiveRecord::Migration
  def change
    create_table :survey_question_choices do |t|
      t.references :survey_multiple_choice_question, null: false
      t.text :option

      t.timestamps
    end
  end
end
