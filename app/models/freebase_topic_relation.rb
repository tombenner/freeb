class FreebaseTopicRelation < ActiveRecord::Base
  attr_accessible :freebase_topic_id, :property, :subject_id, :subject_type

  belongs_to :freebase_topic
  belongs_to :subject, :polymorphic => true
end
