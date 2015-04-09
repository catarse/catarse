class Project::StateValidator < ActiveModel::Validator
  def validate(record)
    @record = record
    self.send record.state
  end

  private
  def online
    in_analysis
    approved
    %w(email address_street address_number address_city address_state address_zip_code phone_number bank agency account account_digit owner_name owner_document account_type).each do |attribute|
      validate_presence_of_nested_attribute(account, attribute)
    end

  end

  def approved
    if (@record.goal || 0) >= CatarseSettings[:minimum_goal_for_video].to_i
      @record.errors.add_on_blank(:video_url)
    end
  end

  def in_analysis
    @record.errors.add_on_blank([:about_html, :headline, :goal, :online_days, :budget])
    %w(name about_html).each do |attribute|
      validate_presence_of_nested_attribute(user, attribute)
    end
    @record.errors.add_on_blank(:uploaded_image) unless @record.video_thumbnail.present?

    @record.errors['user.uploaded_image'] << "Imagem do usuário não pode ficar em branco" if user.uploaded_image.blank?
    @record.errors['rewards.size'] << "Deve haver pelo menos uma recompensa" if @record.rewards.size== 0
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

  def validate_presence_of_nested_attribute(association, attribute_name, &block)
    if block_given?
      if block.call
        add_errors_on(association, attribute_name, :blank)
      end
    elsif association.send(attribute_name).blank?
      add_errors_on(association, attribute_name, :blank)
    end
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
