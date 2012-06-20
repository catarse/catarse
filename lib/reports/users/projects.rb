#encoding:utf-8
module Reports
  module Users
    class Projects
      class << self
        def all_project_owners
          @collection = User.joins(:projects).includes(:projects)

          @csv = CSV.generate(:col_sep => ',') do |csv_string|
            csv_string << [
              'ID projeto',
              'Nome do realizador',
              'Email do realizador',
              'Estado',
              'Cidade',
              'Telefone'
            ]

            @collection.each do |resource|
              csv_string << [
                resource.projects.map(&:id).join(', '),
                resource.name,
                resource.email,
                resource.address_state,
                resource.address_city,
                resource.phone_number
              ]
            end
          end
        end
      end
    end
  end
end
