class CreateUsStates < ActiveRecord::Migration
  def change
    create_table :us_states do |t|
      t.string :freebase_id
      t.string :name
      t.string :area
      
      t.timestamps
    end

    add_index :us_states, :freebase_id
  end
end