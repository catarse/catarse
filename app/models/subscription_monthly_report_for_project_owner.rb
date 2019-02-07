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
		'Valor do apoio (bruto)',
		'Taxa do Catarse', 
		'Taxa do meio de pagamento',
		'Valor do apoio (líquido)',
		'Título da recompensa',	
		'Descrição da recompensa', 
		'Meio de pagamento',	
		'Data do pagamento', 
		'Data de confirmação do pagamento', 
		'Status do pagamento',	
		'ID do usuário', 
		'Anônimo', 
		'Rua', 	
		'Número',	
		'Complemento', 
		'Bairro',	
		'Cidade',	
		'Estado',	
		'CEP'
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
				sub.zipcode
			]
      end
    end
  end

end
