class FreebaseModelRelation < ActiveRecord::Base
  attr_accessible :object_id, :object_type, :property, :subject_id, :subject_type

  belongs_to :object, :polymorphic => true
  belongs_to :subject, :polymorphic => true
end
