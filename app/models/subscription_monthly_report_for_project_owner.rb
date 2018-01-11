# coding: utf-8
class SubscriptionMonthlyReportForProjectOwner < ActiveRecord::Base
  acts_as_copy_target

  scope :project_id, ->(project_id) { where(project_id: project_id) }
  scope :reward_id, ->(reward_id) { where(reward_id: reward_id) }
  scope :created_at, ->(date) { where(created_at: date.to_date .. date.to_date + 1.month) }

  def self.to_csv
    attributes = ['Nome completo',	'Nome público', 'CPF', 'Email perfil Catarse',	'Valor do apoio',	'Título da recompensa',	'Descrição da recompensa', 'Meio de pagamento',	'Data do apoio',	'Status do apoio',	'ID do usuário', 'Anônimo', 'Rua', 'Complemento',	'Número',	'Bairro',	'Cidade',	'Estado',	'CEP']

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |sub|
        csv << [
          sub.name,
          sub.public_name,
          sub.cpf,
          sub.email,
          sub.amount,
          sub.title,
          sub.description,
          I18n.t('projects.subscription_fields.' + sub.payment_method),
          sub.created_at ? I18n.l(sub.created_at.to_date) : '',
          sub.confirmed,
          sub.user_id,
          sub.anonymous,
          sub.street,
          sub.complement,
          sub.number,
          sub.neighborhood,
          sub.city,
          sub.state,
          sub.zipcode
              ]
      end
    end
  end

end
