class CreateSurveyOpenQuestions < ActiveRecord::Migration[4.2]
  def change
    create_table :survey_open_questions do |t|
      t.references :survey, null: false
      t.text :question
      t.text :description

      t.timestamps
    end
  end
end
