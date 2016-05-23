# NOTE: EXPERIMENTAL FEATURE, just need a way to deliver notifications
# where creates directly into database instead rails way
namespace :listen do
  desc 'listen from database and deliver notifications'
  task sync_notifications: [:environment] do
    DirectMessage
    ProjectReport
    $stdout.sync = true
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      conn = connection.instance_variable_get(:@connection)

      log = -> (msg) {
        Rails.logger.info msg
        puts msg
      }

      begin
        log.("STARTING LISTENER...")
        conn.async_exec "LISTEN system_notifications"

        loop do
          conn.wait_for_notify do |channel, pid, payload| 
            if channel == "system_notifications"
              begin
                decoded = ActiveSupport::JSON.decode(payload)
                kclass = decoded["table"].singularize.camelcase.constantize
                resource = kclass.find(decoded["id"])
                deliver_job_id = resource.deliver
                log.("[NOTIFICATIONS] => delivering message #{decoded['table']} - ID: #{decoded['id']} - JOB: #{deliver_job_id}")
              rescue Exception => e
                log.("[NOTIFICATIONS] => #{e.inspect} - payload #{payload.inspect}")
              end
            end
          end
          sleep 0.5
        end
      ensure
        conn.async_exec "UNLISTEN system_notifications"
      end
    end
  end
end
