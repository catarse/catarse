class ProjectAccount < ActiveRecord::Base
  belongs_to :project
  belongs_to :bank

  attr_accessor :person_type

  def entity_type
    cpf.length > 14 ? 'Pessoa Jurídica' : 'Pessoa Física'
  end

end
