class Project::StateValidator < ActiveModel::Validator
  def validate(record)
    @record = record
    self.send record.state
  end

  private
  def online
    in_analysis
    approved
    %w(full_name email cpf address_street address_number address_city address_state address_zip_code phone_number bank agency agency_digit account account_digit owner_name owner_document).each do |attribute|
      validate_presence_of_nested_attribute(account, attribute)
    end
  end

  def approved
    if (@record.goal || 0) >= CatarseSettings[:minimum_goal_for_video].to_i
      @record.errors.add_on_blank(:video_url)
    end
  end

  def in_analysis
    @record.errors.add_on_blank([:about, :headline, :goal, :online_days, :uploaded_image, :budget])
    %w(name bio).each do |attribute|
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
    @record.try(:account)
  end

  private

  def validate_presence_of_nested_attribute(association, attribute_name)
    if association.send(attribute_name).blank?
      association_name = association.class.model_name.i18n_key
      @record.errors["#{association_name}.#{attribute_name}"] << I18n.t("activerecord.errors.models.#{association_name}.attributes.#{attribute_name}.blank")
    end
  end
end
