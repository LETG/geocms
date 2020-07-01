class AddQueryableToLayer < ActiveRecord::Migration[4.2]
  def change
    add_column :geocms_layers, :queryable, :bool
  end
end
