class ProjectAccount < ActiveRecord::Base
  belongs_to :project
  belongs_to :bank

  def entity_type
    if owner_document
      owner_document.length > 14 ? 'Pessoa Jurídica' : 'Pessoa Física'
    else
      'Pessoa Física'
    end
  end

end
