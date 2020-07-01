class AddByDefaultToContexts < ActiveRecord::Migration[4.2]
  def change
    add_column :geocms_contexts, :by_default, :boolean
  end
end
