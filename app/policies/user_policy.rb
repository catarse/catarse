# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def destroy?
    done_by_owner_or_admin? && record.projects.with_state(['online', 'waiting_funds', 'successful']).size <= 0
  end

  def credits?
    done_by_owner_or_admin?
  end

  def redirect_to_user_billing?
    done_by_owner_or_admin?
  end

  def settings?
    done_by_owner_or_admin?
  end

  def billing?
    done_by_owner_or_admin?
  end

  def edit?
    done_by_owner_or_admin?
  end

  def update?
    done_by_owner_or_admin?
  end

  def update_reminders?
    done_by_owner_or_admin?
  end

  def unsubscribe_notifications?
    done_by_owner_or_admin?
  end

  def new_password?
    done_by_owner_or_admin?
  end

  def credit_cards?
    done_by_owner_or_admin?
  end

  def permitted_attributes
    return [] unless user
    u_attrs = [:account_type, :state_inscription, :birth_date, :confirmed_email_at, :public_name, :current_password, :password, :owner_document, :subscribed_to_new_followers, :subscribed_to_project_post, :subscribed_to_friends_contributions, address_attributes: %i[address_street id country_id state_id address_number address_complement address_neighbourhood address_city address_state address_zip_code phone_number], bank_account_attributes: %i[id input_bank_number bank_id name agency account owner_name owner_document account_digit agency_digit account_type]]
    u_attrs << { category_follower_ids: [] }
    u_attrs << record.attribute_names.map(&:to_sym) if record.is_a?(User)
    u_attrs << { links_attributes: %i[id _destroy link] }
    u_attrs << { category_followers_attributes: %i[id user_id category_id] }
    u_attrs << { mail_marketing_users_attributes: %i[id _destroy mail_marketing_list_id] }
    u_attrs = u_attrs.flatten.uniq

    unless user.try(:admin?)
      u_attrs.delete(:zero_credits)
      u_attrs.delete(:permalink)
      u_attrs.delete(:whitelisted_at)

      if user.published_projects.present? || user.contributed_projects.present?
        if user.name.present? && user.cpf.present?
          u_attrs.delete(:name)
          u_attrs.delete(:cpf)
          u_attrs.delete(:account_type)
        end
      end
    end

    u_attrs.flatten
  end

  def ban?
    user.try(:admin?)
  end

  protected

  def done_by_owner_or_admin?
    record == user || user.try(:admin?)
  end
end
