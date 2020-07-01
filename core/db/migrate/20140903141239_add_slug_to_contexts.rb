class AddSlugToContexts < ActiveRecord::Migration[4.2]
  def change
    add_column  :geocms_contexts, :slug, :string
    add_index   :geocms_contexts, :slug
  end
end
