class Subscription < ActiveRecord::Base
  self.table_name = 'common_schema.subscriptions'
  belongs_to :user, primary_key: :common_id
  belongs_to :project, primary_key: :common_id
  belongs_to :reward, primary_key: :common_id
  has_many :subscription_payments

  def self.to_csv(options = {})
    columns = ['Nome completo',	'Nome público', 'Email perfil Catarse',	'Valor do apoio mensal',	'Título da recompensa',	'Descrição da recompensa',	'Total apoiado até hoje', 'Status da Assinatura',	'Meio de pagamento',	'Data de confirmação do último apoio',	'Data de início da Assinatura',	'Tempo de assinatura',	'ID do usuário', 'Anônimo', 'Tipo de endereço', 'Rua',	'Complemento',	'Número',	'Bairro',	'Cidade',	'Estado',	'CEP']
    CSV.generate(options) do |csv|
      csv << columns
      all.each do |subscription|
        total_backed = subscription.subscription_payments.where(status: 'paid').sum("(data->>'amount')::numeric") / 100
        all_payments = subscription.subscription_payments.where(status: 'paid')
        last_payment = all_payments.order('created_at asc').last
        csv << [subscription.user.name,
                subscription.user.public_name,
                subscription.user.email,
                subscription.checkout_data['amount'].to_f / 100,
                subscription.reward.try(:title),
                subscription.reward.try(:description),
                total_backed,
                I18n.t('projects.subscription_fields.status.' + subscription.status),
                I18n.t('projects.subscription_fields.' + subscription.checkout_data['payment_method']),
                last_payment.try(:created_at) ? I18n.l(last_payment.try(:created_at).try(:to_date)) : '',
                subscription.try(:created_at) ? I18n.l(subscription.try(:created_at).try(:to_date)) : '',
                I18n.t('datetime.distance_in_words.x_months', count: all_payments.count),
                subscription.user.id,
                last_payment.nil? ? '' : (last_payment['data']['anonymous'] ? 'Sim' : 'Não'),
                subscription.user.address.nil? ? 'Pagamento' : 'Usuário',
                subscription.checkout_data['customer']['address']['street'] || subscription.user.address.address_street,
                subscription.checkout_data['customer']['address']['complementary'] || subscription.user.address.address_complement,
                subscription.checkout_data['customer']['address']['street_number'] || subscription.user.address.address_number,
                subscription.checkout_data['customer']['address']['neighborhood'] || subscription.user.address.address_neighbourhood,
                subscription.checkout_data['customer']['address']['city'] || subscription.user.address.address_city,
                subscription.checkout_data['customer']['address']['state'] || subscription.user.address.state.acronym,
                subscription.checkout_data['customer']['address']['zipcode'] || subscription.user.address.address_zip_code
                ]
      end
    end
  end
end
