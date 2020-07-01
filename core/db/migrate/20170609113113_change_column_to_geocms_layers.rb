class ChangeColumnToGeocmsLayers < ActiveRecord::Migration[4.2]
  def change
     change_column_default :geocms_layers, :queryable , true
     change_column_null    :geocms_layers, :queryable , true
  end
end
