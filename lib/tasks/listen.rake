# NOTE: EXPERIMENTAL FEATURE, just need a way to deliver notifications
# where creates directly into database instead rails way
namespace :listen do
  desc 'listen from database and deliver notifications'
  task sync_notifications: [:environment] do
    DirectMessage
    ProjectReport
    UserFollow
    $stdout.sync = true
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      conn = connection.instance_variable_get(:@connection)

      begin
        Rails.logger.info("STARTING LISTENER...")
        conn.async_exec "LISTEN system_notifications;"

        loop do
          conn.wait_for_notify do |channel, pid, payload| 
            if channel == "system_notifications"
              begin
                decoded = ActiveSupport::JSON.decode(payload)
                kclass = decoded["table"].singularize.camelcase.constantize
                resource = kclass.find(decoded["id"])
                deliver_job_id = resource.deliver
                Rails.logger.info("[NOTIFICATIONS] => delivering message #{decoded['table']} - ID: #{decoded['id']} - JOB: #{deliver_job_id}")
              rescue Exception => e
                Rails.logger.info("[NOTIFICATIONS] => #{e.inspect} - payload #{payload.inspect}")
              end
            end
          end
          sleep 0.5
        end
      ensure
        Rails.logger.info("unlisten time")
        conn.async_exec "UNLISTEN system_notifications;"
      end
    end
  end


  desc 'listen from database and sync with rdstation'
  task sync_rdstation: [:environment] do
    $stdout.sync = true
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      conn = connection.instance_variable_get(:@connection)
      rdstation_client = RDStation::Client.new(
        CatarseSettings[:rd_token],
        CatarseSettings[:rd_secret_token]
      )

      begin
        Rails.logger.info("STARTING LISTENER...")
        conn.async_exec "LISTEN catartico_rdstation"

        loop do
          conn.wait_for_notify do |channel, pid, payload| 
            if channel == "catartico_rdstation"
              begin
                decoded = ActiveSupport::JSON.decode(payload)
                rd_params = {
                  identificador: decoded['event_name'],
                  email: decoded['email'],
                  nome: decoded["name"]
                }

                if decoded['status'] == 'won'
                  rdstation_client.change_lead_status(
                    rd_params.merge(
                      status: decoded['status'],
                      value: decoded['value']
                    )
                  )
                else
                  rdstation_client.create_lead(rd_params)
                end
                Rails.logger.info("[RD-SYNC] => sync #{payload}")
              rescue Exception => e
                Rails.logger.info("[RD-SYNC] => #{e.inspect} - payload #{payload.inspect}")
              end
            end
          end
          sleep 0.5
        end
      ensure
        Rails.logger.info("unlisten time rdstation")
        conn.async_exec "UNLISTEN system_notifications;"
      end
    end
  end
end
