class Project::StateValidator < ActiveModel::Validator
  def validate(record)
    @record = record
    self.send record.state
  end

  private
  def online
    @record.errors[:base] << "Razão social do usuário não pode ficar em branco" if @record.user.full_name.blank?
    @record.errors[:base] << "Email do usuário não pode ficar em branco" if @record.user.email.blank?
    @record.errors[:base] << "CPF do usuário não pode ficar em branco" if @record.user.cpf.blank?
  end

  def approved
    if @record.goal >= CatarseSettings[:minimum_goal_for_video].to_i
      @record.errors.add_on_blank(:video_url)
    end
  end

  def in_analysis
    @record.errors.add_on_blank([:about, :headline, :goal, :online_days])
    @record.errors[:base] << "Nome do usuário não pode ficar em branco" if @record.user.name.blank?
    @record.errors[:base] << "Biografia do usuário não pode ficar em branco" if @record.user.bio.blank?
    @record.errors[:base] << "Imagem do usuário não pode ficar em branco" if @record.user.uploaded_image.blank?
    @record.errors[:base] << "Deve haver pelo menos uma recompensa" if @record.rewards.count == 0
  end

  def draft; end
  def rejected; end
  def successful; end
  def waiting_funds; end
  def failed; end
  def deleted; end
end
