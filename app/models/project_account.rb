class ProjectAccount < ActiveRecord::Base
  belongs_to :project
  belongs_to :bank

  validates_presence_of :email, :address_street, :address_number, :address_city, :address_state, :address_zip_code, :phone_number, :bank, :agency, :account, :account_digit, :owner_name, :owner_document, :account_type

  def entity_type
    if owner_document
      owner_document.length > 14 ? 'Pessoa Jurídica' : 'Pessoa Física'
    else
      'Pessoa Física'
    end
  end

end
