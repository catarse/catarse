#encoding:utf-8
module Reports
  module Users
    class Emails
      class << self
        def all_emails
          @collection= User.primary.select('name, nickname, email').group('name, nickname, email')

          @csv = CSV.generate(:col_sep => ',') do |csv_string|
            csv_string << [
              'Nome',
              'Apelido',
              'Email'
            ]

            @collection.each do |resource|
              csv_string << [
                resource.name,
                resource.nickname,
                resource.email
              ]
            end
          end
        end
      end
    end
  end
end
