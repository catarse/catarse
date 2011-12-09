#encoding:utf-8
module Reports
  module Financial
    class Backers
      class << self
        def report(project_id)
          @project = Project.find(project_id)
          @backers = @project.backers.confirmed

          @csv = CSV.generate(:col_sep => ';') do |csv_string|

            # TODO: Change this later *order and names to use i18n*
            # for moment header only in portuguese.
            csv_string << [
              'Nome do apoiador',
              'Valor do apoio',
              'Recompensa selecionada (valor)',
              'Serviço de pagamento',
              'Forma de pagamento',
              'Taxa do meio de pagamento',
              'ID da transacao',
              'Data do apoio',
              'Data do pagamento confirmado',
              'Email (conta do apoiador)',
              'Email (conta em que fez o pagamento)',
              'Login do usuario no MoIP',
            ]

            @backers.each do |backer|
              csv_string << [
                backer.user.name,
                backer.value.to_s.gsub(/\./,","),
                (backer.reward.minimum_value.to_s.gsub(/\./,",") if backer.reward),
                backer.payment_method,
                (backer.payment_detail.payment_method if backer.payment_detail),
                (backer.payment_service_fee).to_s.gsub(/\./,","),
                backer.key,
                I18n.l(backer.created_at.to_date),
                I18n.l(backer.confirmed_at.to_date),
                backer.user.email,
                (backer.payment_detail.payer_email if backer.payment_detail),
                (backer.payment_detail.payer_name if backer.payment_detail),
              ]
            end
          end
        end
      end
    end
  end
end