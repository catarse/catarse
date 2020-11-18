FactoryBot.define do
  factory :script, class: 'CatarseScripts::Script' do
    association :creator, factory: :user
    association :executor, factory: :user
    status { CatarseScripts::Script.statuses.keys.sample }
    title { 'Script' }
    description { 'Basic description' }
    code do
      <<-RUBY
        class <ScriptClassName>
          def call(worker = nil)

          end
        end
      RUBY
    end
    class_name { 'Script123' }
    ticket_url { 'http://example.com' }
    tags { ['tag1', 'tag2'] }
  end
end
