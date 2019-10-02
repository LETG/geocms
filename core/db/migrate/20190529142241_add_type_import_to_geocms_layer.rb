class AddTypeImportToGeocmsLayer < ActiveRecord::Migration
  def change
    add_column :geocms_layers, :type_import, :string
  end
end
