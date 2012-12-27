class CreateFreebaseModelRelations < ActiveRecord::Migration
  def change
    create_table :freebase_model_relations do |t|
      t.string :subject_type
      t.integer :subject_id
      t.string :property
      t.string :object_type
      t.integer :object_id

      t.timestamps
    end

    add_index :freebase_model_relations, [:subject_type, :subject_id, :property, :object_type, :object_id], :name => "freebase_topic_relations_triple"
  end
end
