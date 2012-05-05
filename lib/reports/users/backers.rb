#encoding:utf-8
module Reports
  module Users
    class Backers
      class << self
        def all_confirmed_backers
          @backers = Backer.confirmed.includes(:project, :reward)

          @csv = CSV.generate(:col_sep => ',') do |csv_string|
            csv_string << [
              'Valor',
              'Recompensa Selecionada Valor',
              'Feito em',
              'Projeto',
              'Bem sucedido?',
              'Termina em',
              'Categoria'
            ]

            @backers.each do |backer|
              csv_string << [
                backer.value,
                (backer.reward.minimum_value if backer.reward),
                (backer.created_at.strftime("%d/%m/%Y") if backer.created_at),
                backer.project.name,
                (backer.project.successful? ? 'Sim' : 'Não'),
                (backer.expires_at.strftime("%d/%m/%Y") if backer.expires_at),
                backer.project.category.name
              ]
            end
          end
        end

        def most_backed(limit=50)
          @users = User.most_backeds.limit(limit)

          @csv = CSV.generate(:col_sep => ',') do |csv_string|

            # TODO: Change this later *order and names to use i18n*
            # for moment header only in portuguese.
            csv_string << [
              'ID',
              'Nome do apoiador',
              'Email',
              'Total de apoios',
              'Valor total'
            ]

            @users.each do |user|
              csv_string << [
                user.id,
                user.display_name,
                user.email,
                user.count_backs,
                user.display_total_of_backs
              ]
            end
          end
        end
      end
    end
  end
end
