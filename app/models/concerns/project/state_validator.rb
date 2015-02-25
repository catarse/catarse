class Project::StateValidator < ActiveModel::Validator
  def validate(record)
    @record = record
    self.send record.state
  end

  private
  def online
    in_analysis
    approved
    %w(full_name email cpf address_street address_number address_city address_state address_zip_code phone_number bank agency account account_digit owner_name owner_document account_type).each do |attribute|
      validate_presence_of_nested_attribute(account, attribute)
    end

    validate_same_value_of(account, :owner_document, :cpf)
  end

  def approved
    if (@record.goal || 0) >= CatarseSettings[:minimum_goal_for_video].to_i
      @record.errors.add_on_blank(:video_url)
    end
  end

  def in_analysis
    @record.errors.add_on_blank([:about, :headline, :goal, :online_days, :uploaded_image, :budget])
    %w(name about).each do |attribute|
      validate_presence_of_nested_attribute(user, attribute)
    end
    @record.errors['user.uploaded_image'] << "Imagem do usuário não pode ficar em branco" if user.personal_image.blank?
    #@record.errors['rewards.size'] << "Deve haver pelo menos uma recompensa" if @record.rewards.count == 0
  end

  def draft; end
  def rejected; end
  def successful; end
  def waiting_funds; end
  def failed; end
  def deleted; end

  def user
    @record.user
  end

  def account
    @record.try(:account) || @record.build_account
  end

  def validate_presence_of_nested_attribute(association, attribute_name)
    add_errors_on(association, attribute_name, :blank) if association.send(attribute_name).blank?
  end

  def validate_same_value_of(association, attribute_name, other_attribute)
    add_errors_on(association, attribute_name, :not_same) if association.send(attribute_name) != association.send(other_attribute)
  end

  def add_errors_on(association, attribute_name, i18n_error_key)
    @record.errors["#{association_name(association)}.#{attribute_name}"] << error_message_for(association, attribute_name, i18n_error_key)
    association.errors[attribute_name.to_sym] << error_message_for(association, attribute_name, i18n_error_key)
  end

  def association_name(association)
    association.class.model_name.i18n_key
  end

  def error_message_for(association, attribute_name, i18n_error_key)
    I18n.t("activerecord.errors.models.#{association_name(association)}.attributes.#{attribute_name}.#{i18n_error_key}")
  end
end
