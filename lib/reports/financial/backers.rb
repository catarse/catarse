#encoding:utf-8
module Reports
  module Financial
    class Backers
      class << self
        def report(project_id)
          @project = Project.find(project_id)
          @backers = @project.backers.includes(:payment_detail, :user).confirmed

          @csv = CSV.generate(:col_sep => ',') do |csv_string|

            # TODO: Change this later *order and names to use i18n*
            # for moment header only in portuguese.
            csv_string << [
              'Nome do apoiador',
              'Valor do apoio',
              'Recompensa selecionada (valor)',
              'Recompensa selecionada (nome)',
              'Serviço de pagamento',
              'Forma de pagamento',
              'Taxa do meio de pagamento',
              'ID da transacao',
              'Data do apoio',
              'Data do pagamento confirmado',
              'Email (conta do apoiador)',
              'Email (conta em que fez o pagamento)',
              'Login do usuario no MoIP',
              'CPF',
              'Endereço',
              'Complemento',
              'Numero',
              'Bairro',
              'Cidade',
              'Estado',
              'CEP',
              'Solicitou estorno',
              'Estorno Realizado'
            ]

            @backers.each do |backer|
              csv_string << [
                backer.user.name,
                backer.value,
                (backer.reward.minimum_value if backer.reward),
                (backer.reward.description if backer.reward),
                backer.payment_method,
                (backer.payment_detail.payment_method if backer.payment_detail),
                (backer.payment_service_fee),
                backer.key,
                I18n.l(backer.created_at.to_date),
                I18n.l(backer.confirmed_at.to_date),
                backer.user.email,
                (backer.payment_detail.payer_email if backer.payment_detail),
                (backer.payment_detail.payer_name if backer.payment_detail),
                backer.user.cpf,
                backer.user.address_street,
                backer.user.address_complement,
                backer.user.address_number,
                backer.user.address_neighbourhood,
                backer.user.address_city,
                backer.user.address_state,
                backer.user.address_zip_code,
                backer.requested_refund,
                backer.refunded
              ]
            end
          end
        end
      end
    end
  end
end
