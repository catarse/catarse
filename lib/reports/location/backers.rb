#encoding:utf-8
module Reports
  module Location
    class Backers
      class << self
        def report(project_id)
          @project = Project.find(project_id)
          @backers = @project.backers.includes(:user).confirmed

          @csv = CSV.generate(:col_sep => ',') do |csv_string|

            # TODO: Change this later *order and names to use i18n*
            # for moment header only in portuguese.
            csv_string << [
              'Nome do apoiador',
              'Cidade',
              'Estado'
            ]

            @backers.each do |backer|
              csv_string << [
                backer.user.name,
                backer.user.address_city,
                backer.user.address_state,
              ]
            end
          end
        end
      end
    end
  end
end
