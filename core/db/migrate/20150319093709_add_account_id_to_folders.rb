class AddAccountIdToFolders < ActiveRecord::Migration[4.2]
  def change
    add_column :geocms_folders, :account_id, :integer
  end
end
