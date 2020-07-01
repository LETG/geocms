class AddTypeImportToGeocmsLayer < ActiveRecord::Migration[4.2]
  def change
    add_column :geocms_layers, :type_import, :string
  end
end
