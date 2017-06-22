# frozen_string_literal: true

Statesman.configure do
  storage_adapter(Statesman::Adapters::ActiveRecord)
end
