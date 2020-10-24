class AddCardOwnerDocumentToContributions < ActiveRecord::Migration[4.2]
  def change
    add_column :contributions, :card_owner_document, :string
  end
end
