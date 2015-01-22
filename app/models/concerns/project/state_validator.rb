class Project::StateValidator < ActiveModel::Validator
  def validate(record)
    @record = record
    self.send record.state
  end

  private
  def online
    in_analysis
    approved
    @record.errors['user.full_name'] << "Razão social do usuário não pode ficar em branco" if user.full_name.blank?
    @record.errors['user.email'] << "Email do usuário não pode ficar em branco" if user.email.blank?
    @record.errors['user.cpf'] << "CPF do usuário não pode ficar em branco" if user.cpf.blank?
    @record.errors['user.address_street'] << "Endereço do usuário não pode ficar em branco" if user.address_street.blank?
    @record.errors['user.address_number'] << "Número no endereço do usuário não pode ficar em branco" if user.address_number.blank?
    @record.errors['user.address_city'] << "Cidade do usuário não pode ficar em branco" if user.address_city.blank?
    @record.errors['user.address_state'] << "Estado do usuário não pode ficar em branco" if user.address_state.blank?
    @record.errors['user.address_zip_code'] << "CEP do usuário não pode ficar em branco" if user.address_zip_code.blank?
    @record.errors['user.phone_number'] << "Telefone do usuário não pode ficar em branco" if user.phone_number.blank?

    @record.errors['user.bank_account.bank'] << "Banco do usuário não pode ficar em branco" if bank_account.try(:bank).blank?
    @record.errors['user.bank_account.agency'] << "Agência do usuário não pode ficar em branco" if bank_account.try(:agency).blank?
    @record.errors['user.bank_account.agency_digit'] << "Dígito agência do usuário não pode ficar em branco" if bank_account.try(:agency_digit).blank?
    @record.errors['user.bank_account.account'] << "No. da conta do usuário não pode ficar em branco" if bank_account.try(:account).blank?
    @record.errors['user.bank_account.account_digit'] << "Dígito conta do usuário não pode ficar em branco" if bank_account.try(:account_digit).blank?
    @record.errors['user.bank_account.owner_name'] << "Nome do titular do usuário não pode ficar em branco" if bank_account.try(:owner_name).blank?
    @record.errors['user.bank_account.owner_document'] << "CPF / CNPJ do titular do usuário não pode ficar em branco" if bank_account.try(:owner_document).blank?
  end

  def approved
    if (@record.goal || 0) >= CatarseSettings[:minimum_goal_for_video].to_i
      @record.errors.add_on_blank(:video_url)
    end
  end

  def in_analysis
    @record.errors.add_on_blank([:about, :headline, :goal, :online_days, :budget, :uploaded_image, :permalink])
    @record.errors['user.name'] << "Nome do usuário não pode ficar em branco" if user.name.blank?
    @record.errors['user.bio'] << "Biografia do usuário não pode ficar em branco" if user.bio.blank?
    @record.errors['user.uploaded_image'] << "Imagem do usuário não pode ficar em branco" if user.uploaded_image.blank?
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

  def bank_account
    @record.user.try(:bank_account)
  end
end
