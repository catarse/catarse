class Project::StateValidator < ActiveModel::Validator
  def validate(record)
    @record = record
    self.send record.state
  end

  private
  def online
    in_analysis
    approved
    @record.errors['account.full_name'] << "Razão social do usuário não pode ficar em branco" if account.try(:full_name).blank?
    @record.errors['account.email'] << "Email do usuário não pode ficar em branco" if account.try(:email).blank?
    @record.errors['account.cpf'] << "CPF do usuário não pode ficar em branco" if account.try(:cpf).blank?
    @record.errors['account.address_street'] << "Endereço do usuário não pode ficar em branco" if account.try(:address_street).blank?
    @record.errors['account.address_number'] << "Número no endereço do usuário não pode ficar em branco" if account.try(:address_number).blank?
    @record.errors['account.address_city'] << "Cidade do usuário não pode ficar em branco" if account.try(:address_city).blank?
    @record.errors['account.address_state'] << "Estado do usuário não pode ficar em branco" if account.try(:address_state).blank?
    @record.errors['account.address_zip_code'] << "CEP do usuário não pode ficar em branco" if account.try(:address_zip_code).blank?
    @record.errors['account.phone_number'] << "Telefone do usuário não pode ficar em branco" if account.try(:phone_number).blank?

    @record.errors['account.bank'] << "Banco do usuário não pode ficar em branco" if account.try(:bank).blank?
    @record.errors['account.agency'] << "Agência do usuário não pode ficar em branco" if account.try(:agency).blank?
    @record.errors['account.agency_digit'] << "Dígito agência do usuário não pode ficar em branco" if account.try(:agency_digit).blank?
    @record.errors['account.account'] << "No. da conta do usuário não pode ficar em branco" if account.try(:account).blank?
    @record.errors['account.account_digit'] << "Dígito conta do usuário não pode ficar em branco" if account.try(:account_digit).blank?
    @record.errors['account.owner_name'] << "Nome do titular do usuário não pode ficar em branco" if account.try(:owner_name).blank?
    @record.errors['account.owner_document'] << "CPF / CNPJ do titular do usuário não pode ficar em branco" if account.try(:owner_document).blank?
  end

  def approved
    if (@record.goal || 0) >= CatarseSettings[:minimum_goal_for_video].to_i
      @record.errors.add_on_blank(:video_url)
    end
  end

  def in_analysis
    @record.errors.add_on_blank([:about, :headline, :goal, :online_days, :uploaded_image, :budget])
    @record.errors['user.name'] << "Nome do usuário não pode ficar em branco" if user.name.blank?
    @record.errors['user.bio'] << "Biografia do usuário não pode ficar em branco" if user.bio.blank?
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
end
