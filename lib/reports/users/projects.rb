#encoding:utf-8
module Reports
  module Users
    class Projects
      class << self
        def all_project_owners
          @collection = User.joins(:projects).where('projects.visible is true').includes(:projects)

          @csv = CSV.generate(:col_sep => ',') do |csv_string|
            csv_string << [
              'ID projeto',
              'Nome do projeto',
              'Projeto bem sucedido?',
              'Nome do realizador',
              'Email do realizador',
              'Estado',
              'Cidade',
              'Telefone'
            ]

            @collection.each do |resource|
              resource.projects.each do |project|
                csv_string << [
                  project.id,
                  project.name,
                  (project.successful? ? 'Sim' : 'Nao'),
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
end
