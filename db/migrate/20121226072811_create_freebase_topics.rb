class CreateFreebaseTopics < ActiveRecord::Migration
  def change
    create_table :freebase_topics do |t|
      t.string :freebase_id
      t.string :name

      t.timestamps
    end

    add_index :freebase_topics, :freebase_id
  end
end
