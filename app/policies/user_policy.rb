class UserPolicy < ApplicationPolicy
  def destroy?
    done_by_owner_or_admin?
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

  def permitted_attributes
    u_attrs = [:current_password, :password, :subscribed_to_new_followers, :subscribed_to_project_post, :subscribed_to_friends_contributions, bank_account_attributes: [:id, :input_bank_number, :bank_id, :name, :agency, :account, :owner_name, :owner_document, :account_digit, :agency_digit] ]
    u_attrs << { category_follower_ids: [] }
    u_attrs << record.attribute_names.map(&:to_sym)
    u_attrs << { links_attributes: [:id, :_destroy, :link] }
    u_attrs << { category_followers_attributes: [:id, :user_id, :category_id] }
    u_attrs.flatten!

    unless user.try(:admin?)
      u_attrs.delete(:zero_credits)
      u_attrs.delete(:permalink)
    end

    u_attrs.flatten
  end

  protected
  def done_by_owner_or_admin?
    record == user || user.try(:admin?)
  end
end

