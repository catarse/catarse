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
              'Forma de pagamento',
              'Taxa do meio de pagamento',
              'ID da transacao',
              'Data do apoio',
              'Data do pagamento',
              'Email (conta do apoiador)',
              'Email (conta em que fez o pagamento)',
              'Login do usuario no MoIP',
            ]

            @backers.each do |backer|
              csv_string << [
                backer.user.name,
                backer.value,
                (backer.reward.minimum_value if backer.reward),
                (backer.payment_detail.try(:payment_method) if backer.payment_detail),
                (backer.payment_detail.try(:service_tax_amount)  if backer.payment_detail),
                backer.key,
                (backer.payment_detail.try(:display_payment_date) if backer.payment_detail),
                backer.confirmed_at,
                backer.user.email,
                (backer.payment_detail.try(:payer_email) if backer.payment_detail),
                (backer.payment_detail.try(:payer_name) if backer.payment_detail),
              ]
            end
          end
        end
      end
    end
  end
end