# coding: utf-8
class SubscriptionMonthlyReportForProjectOwner < ActiveRecord::Base
  acts_as_copy_target

  scope :project_id, ->(project_id) { where(project_id: project_id) }
  scope :reward_id, ->(reward_id) { where(reward_id: reward_id) }

  def self.to_csv
    attributes = [
			'Nome completo',
			'Nome público',
			'CPF',
			'Email perfil Catarse',
			'Valor do pagamento (bruto)',
			'Taxa do Catarse',
			'Taxa do meio de pagamento',
			'Taxa do serviço de antifraude',
			'Valor do pagamento (líquido)',
			'Título da recompensa',
			'Descrição da recompensa',
			'Meio de pagamento',
			'Data da cobrança',
			'Data de confirmação da cobrança',
			'Status da cobrança',
			'ID do usuário',
			'Anônimo',
			'Rua',
			'Número',
			'Complemento',
			'Bairro',
			'Cidade',
			'Estado',
			'CEP',
			'País'
    ]

    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.order(:created_at).each do |sub|
				csv << [
					sub.name,
					sub.public_name,
					sub.cpf,
					sub.email,
					sub.amount,
					sub.service_fee,
					sub.payment_method_fee,
					sub.antifraud_cost,
					sub.net_value,
					sub.title,
					sub.description,
					I18n.t('projects.subscription_fields.' + sub.payment_method),
					sub.created_at ? I18n.l(sub.created_at.to_date) : '',
					sub.paid_at ? I18n.l(sub.paid_at.to_date) : '',
					sub.confirmed,
					sub.user_id,
					sub.anonymous,
					sub.street,
					sub.number,
					sub.complement,
					sub.neighborhood,
					sub.city,
					sub.state,
					sub.zipcode,
					sub.country
				]
      end
    end
  end

end
