#encoding:utf-8
module Reports
  module Users
    class Emails
      class << self
        def all_emails
          @collection= User.primary.select('email').group('email')

          @csv = CSV.generate(:col_sep => ',') do |csv_string|
            csv_string << [
              'Email'
            ]

            @collection.each do |resource|
              csv_string << [
                resource.email
              ]
            end
          end
        end
      end
    end
  end
end
