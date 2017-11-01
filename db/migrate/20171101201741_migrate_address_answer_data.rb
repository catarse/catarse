class MigrateAddressAnswerData < ActiveRecord::Migration
  def change
    # make sure we have no duplicated answers
    execute <<-SQL
    delete from survey_address_answers where id in (
    select id from survey_address_answers where contribution_id in (
    select contribution_id
    from survey_address_answers sa
    group by contribution_id
    having count(*)>1)
    and id not in (
    select distinct max(id) over(partition by contribution_id) from survey_address_answers where contribution_id in (
    select contribution_id
    from survey_address_answers sa
    group by contribution_id
    having count(*)>1)) );
    SQL

    SurveyAddressAnswer.all.each do |answer|
      contribution = Contribution.find answer.contribution_id
      contribution.update_attribute :address_answer_id, answer.address_id
    end
  end
end
