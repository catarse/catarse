#encoding:utf-8
module Reports
  module Financial
    class Backers
      class << self
        def report(project_id)
          @project = Project.find(project_id)
          @backers = @project.backers

          @csv = CSV.generate(:col_sep => ';') do |csv_string|

            # TODO: Change this later *order and names to use i18n*
            # for moment header only in portuguese.
            csv_string << [
              'Login apoiador',
              'ID do usuario do apoiador',
              'Nome do apoiador',
              'Valor do apoio',
              'Recompensa selecionada (valor)',
              'Projeto apoiado',
              'Forma de pagamento',
              'Taxa do catarse',
              'Taxa do meio de pagamento',
              'ID da transacao',
              'Data do pagamento (horario realizado)',
              'Data do pagamento (quando foi confirmado)',
              'Data em que o credito ficara disponivel (so para pagamentos em Cartao de Credito, pelo MoIP)',
              'Cidade',
              'Estado',
              'Telefone',
              'Email (conta do apoiador)',
              'Email (conta em que fez o pagamento)',
              'Quantidade de apoios ja realizados por este login',
              'Apoio anonimo?',
              'Apoio confirmado?',
              'Login do usuario no MoIP',
              'Usou creditos?',
              'Solicitou estorno?',
              'Estorno realizado?',
              'Observações'
            ]

            @backers.each do |backer|
              csv_string << [
                backer.user.display_nickname,
                backer.user.id,
                backer.user.name,
                backer.value,
                (backer.reward.minimum_value if backer.reward),
                backer.project.name,
                (backer.payment_detail.try(:payment_method) if backer.payment_detail),
                backer.catarse_tax(7.5),
                (backer.payment_detail.try(:service_tax_amount)  if backer.payment_detail),
                backer.key,
                (backer.payment_detail.try(:display_payment_date) if backer.payment_detail),
                backer.confirmed_at,
                'Available credit date',
                (backer.payment_detail.try(:city) if backer.payment_detail),
                (backer.payment_detail.try(:uf) if backer.payment_detail),
                backer.user.phone_number,
                backer.user.email,
                (backer.payment_detail.try(:payer_email) if backer.payment_detail),
                backer.user.backs.length,
                backer.anonymous ? 'Sim' : 'Nao',
                backer.confirmed ? 'Sim' : 'Nao',
                (backer.payment_detail.try(:payer_name) if backer.payment_detail),
                backer.credits ? 'Sim' : 'Nao',
                backer.requested_refund ? 'Sim' : 'Nao',
                backer.refunded ? 'Sim' : 'Nao',
                ''
              ]
            end
          end
        end
      end
    end
  end
end