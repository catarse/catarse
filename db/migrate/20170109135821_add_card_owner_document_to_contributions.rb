class AddCardOwnerDocumentToContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :card_owner_document, :string
  end
end
