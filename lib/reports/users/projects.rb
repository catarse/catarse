#encoding:utf-8
module Reports
  module Users
    class Projects
      class << self
        def all_projects_that_expires_in_dez
          @collection = Project.visible.where(:expires_at => '2012-12-01'..'2012-12-31')

          @csv = CSV.generate(:col_sep => ', ') do |csv_string|
            csv_string << [
              'Nome',
              'Data de expiração',
              'Link'
            ]

            @collection.each do |resource|
              csv_string << [
                resource.name,
                (resource.expires_at.strftime('%d/%m/%Y') rescue ''),
                (resource.permalink ? "http://catarse.me/pt/#{resource.permalink}" : "http://catarse.me/pt/projects/#{resource.id}")
              ]
            end
          end
        end

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
