class FreebaseTopic < ActiveRecord::Base
  attr_accessible :freebase_id, :name

  has_many :freebase_topic_relations

  def to_s
    name
  end
end
