# This migration comes from freeb (originally 20121226073507)
class CreateFreebaseTopicRelations < ActiveRecord::Migration
  def change
    create_table :freebase_topic_relations do |t|
      t.string :subject_type
      t.integer :subject_id
      t.string :property
      t.integer :freebase_topic_id

      t.timestamps
    end

    add_index :freebase_topic_relations, [:subject_type, :subject_id, :property], :name => "subject_property"
    add_index :freebase_topic_relations, :freebase_topic_id
  end
end
