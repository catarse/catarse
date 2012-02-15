#encoding:utf-8
module Reports
  module Users
    class Backers
      class << self
        def most_backed(limit=20)
          @users = User.joins(:backs).select(
          <<-SQL
            users.id,
            users.name,
            count(backers.id) as count_backs
          SQL
          ).
          where("backers.confirmed is true").
          order("count_backs desc").
          group("users.name, users.id").
          limit(limit)

          @csv = CSV.generate(:col_sep => ',') do |csv_string|

            # TODO: Change this later *order and names to use i18n*
            # for moment header only in portuguese.
            csv_string << [
              'ID',
              'Nome do apoiador',
              'Total de apoios'
            ]

            @users.each do |user|
              csv_string << [
                user.id,
                user.display_name,
                user.count_backs
              ]
            end
          end
        end
      end
    end
  end
end