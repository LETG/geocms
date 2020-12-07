class AddMinMaxToContexts < ActiveRecord::Migration[4.2]
  def change
    add_column :geocms_contexts, :minx, :float
    add_column :geocms_contexts, :miny, :float
    add_column :geocms_contexts, :maxx, :float
    add_column :geocms_contexts, :maxy, :float
  end
end
