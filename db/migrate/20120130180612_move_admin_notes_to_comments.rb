class MoveAdminNotesToComments < ActiveRecord::Migration
  def self.up
    if index_exists?(:admin_notes, [:admin_user_type, :admin_user_id])
      remove_index  :admin_notes, [:admin_user_type, :admin_user_id]
    end

    if ActiveRecord::Base.connection.tables.include?(:admin_notes)
      rename_table  :admin_notes, :active_admin_comments
      rename_column :active_admin_comments, :admin_user_type, :author_type
      rename_column :active_admin_comments, :admin_user_id, :author_id
      add_column    :active_admin_comments, :namespace, :string
      add_index     :active_admin_comments, [:namespace]
      add_index     :active_admin_comments, [:author_type, :author_id]
    end

    # Update all the existing comments to the default namespace
    if ActiveRecord::Base.connection.tables.include?(:active_admin_comments)
      say "Updating any existing comments to the #{ActiveAdmin.application.default_namespace} namespace."
      execute "UPDATE active_admin_comments SET namespace='#{ActiveAdmin.application.default_namespace}'"
    end
  end

  def self.down
    if index_exists?(:active_admin_comments, :column => [:author_type, :author_id])
      remove_index  :active_admin_comments, :column => [:author_type, :author_id]
    end

    if index_exists?(:active_admin_comments, :column => [:namespace])
      remove_index  :active_admin_comments, :column => [:namespace]
    end

    if ActiveRecord::Base.connection.tables.include?(:active_admin_comments)
      remove_column :active_admin_comments, :namespace
      rename_column :active_admin_comments, :author_id, :admin_user_id
      rename_column :active_admin_comments, :author_type, :admin_user_type
      rename_table  :active_admin_comments, :admin_notes
      add_index     :admin_notes, [:admin_user_type, :admin_user_id]
    end
  end
end
