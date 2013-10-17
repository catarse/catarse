class ChangeVarcharToTextInChannels < ActiveRecord::Migration
  def up
    execute "
      ALTER TABLE channels ALTER name TYPE text;
      ALTER TABLE channels ALTER description TYPE text;
      ALTER TABLE channels ALTER description SET NOT NULL;
      ALTER TABLE channels ALTER permalink TYPE text;
      ALTER TABLE channels ALTER permalink SET NOT NULL;
      ALTER TABLE channels ALTER twitter TYPE text;
      ALTER TABLE channels ALTER facebook TYPE text;
      ALTER TABLE channels ALTER email TYPE text;
      ALTER TABLE channels ALTER image TYPE text;
      ALTER TABLE channels ALTER website TYPE text;
      ALTER TABLE channels ALTER video_url TYPE text;
    "
  end
end
