class SorceryExternal < ActiveRecord::Migration[5.2]
  def change
    create_table :geocms_authentications do |t|
      t.integer :user_id, :null => false
      t.string :provider, :uid, :null => false

      t.timestamps
    end

    add_index :geocms_authentications, [:provider, :uid]
  end
end