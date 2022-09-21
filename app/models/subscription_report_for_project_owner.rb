# coding: utf-8
# frozen_string_literal: true

class SubscriptionReportForProjectOwner < ApplicationRecord
  acts_as_copy_target

  scope :project_id, ->(project_id) { where(project_id: project_id) }
  scope :reward_id, ->(reward_id) { where(reward_id: reward_id) }
  scope :status, ->(status) { where(status: status) }

  def self.to_csv
    attributes = [
      'Nome completo',	'Nome público', 'CPF', 'Telefone', 'Email perfil Catarse',	'Valor do pagamento mensal',
      'Título da recompensa',	'Descrição da recompensa',	'Total pago até hoje', 'Status da Assinatura',
      'Meio de pagamento',	'Data de confirmação da última cobrança',	'Data de início da Assinatura',
      'Qtde. de pagamentos confirmados',	'ID do usuário', 'Anônimo', 'Rua', 'Número', 'Complemento', 'Bairro',
      'Cidade',	'Estado',	'CEP', 'País'
    ]
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |sub|
        csv << [
          sub.name,
          sub.public_name,
          sub.cpf,
          sub.phone_number,
          sub.email,
          sub.amount,
          sub.title,
          sub.description,
          sub.total_backed,
          I18n.t('projects.subscription_fields.status.' + sub.status),
          I18n.t('projects.subscription_fields.' + sub.payment_method),
          sub.last_paid_at,
          sub.started_at,
          I18n.t('datetime.distance_in_words.x_months', count: sub.payments_count),
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
