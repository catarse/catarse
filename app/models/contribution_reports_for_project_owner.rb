class ContributionReportsForProjectOwner < ActiveRecord::Base
  acts_as_copy_target

  belongs_to :payment

  scope :project_id, ->(project_id) { where(project_id: project_id) }
  scope :reward_id, ->(reward_id) { where(reward_id: reward_id) }
  scope :state, ->(state) { where(state: state) }
  scope :waiting_payment, -> { where(waiting_payment: true) }
  scope :project_owner_id, ->(project_owner_id) { where(project_owner_id: project_owner_id) }

  def self.to_csv(collection, reward_id)
    attributes = collection.first.attributes.keys
    attributes.delete('open_questions')
    attributes.delete('multiple_choice_questions')

    CSV.generate(headers: true) do |csv|
      base_attributes = attributes.clone
      survey = Survey.find_by_reward_id reward_id
      if survey
        survey.survey_open_questions.each do |open_question|
          attributes << open_question.question
        end
        survey.survey_multiple_choice_questions.each do |mc_question|
          attributes << mc_question.question
        end
      end

      csv << attributes

      collection.each do |contribution|
        row = base_attributes.map{ |attr| contribution.send(attr) }
        if survey
          row += contribution.open_questions.map{ |attr| attr['answer'] } if contribution.open_questions
          row += contribution.multiple_choice_questions.map do |question|
            question['question_choices'].find {|c| c['id'] == question['survey_question_choice_id']}.try(:[], 'option')
          end if contribution.multiple_choice_questions
        end

        csv << row
      end
    end
  end

  def self.report(remove_keys=true)
    report_sql = "".dup
    keys = I18n.t('contribution_report_to_project_owner').keys
    keys.delete :open_questions if remove_keys
    keys.delete :multiple_choice_questions if remove_keys
    keys.each do |column|
      report_sql << "#{column} AS \"#{I18n.t("contribution_report_to_project_owner.#{column}")}\","
    end

    select(%(
        #{report_sql}
        CASE WHEN anonymous='t' THEN '#{I18n.t('yes')}'
            WHEN anonymous='f' THEN '#{I18n.t('no')}'
        END as "#{I18n.t('contribution_report_to_project_owner.anonymous')}"
      ))
  end
end
