class AddTypeImportToGeocmsLayer < ActiveRecord::Migration[4.2]
  def change
    add_column :geocms_accounts, :private, :boolean, default: false
  end
end
