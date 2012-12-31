module Freeb
  class Converter
    def self.freebase_id_to_topic(freebase_id, model)
      config = ModelConfig.get(model)
      query_properties = ModelConfig.get_query_properties(model)
      mql = {
        :id => freebase_id,
        :type => config[:type],
        :name => nil
      }.merge(query_properties)
      API.topic(mql)
    end

    def self.name_to_topic(name, model)
      config = ModelConfig.get(model)
      query_properties = ModelConfig.get_query_properties(model)
      mql = {
        :id => nil,
        :type => config[:type],
        :name => name
      }.merge(query_properties)
      API.topic(mql)
    end

    def self.topic_to_record_attributes(topic, model)
      config = ModelConfig.get(model)
      attributes = {
        :freebase_id => topic.id,
        :name => topic.name
      }
      config[:properties].each do |key, property_config|
        if property_config[:method].blank?
          attributes[key] = topic[property_config[:id]]
        else
          attributes[key] = model.send(property_config[:method], topic)
        end
      end
      config[:topics].each do |key, topic_config|
        attributes[key] = topic[topic_config[:id]].collect { |hash| topic_hash_to_freebase_topic_record(hash) }
      end
      config[:has_many].each do |key, association_config|
        records = topic[association_config[:id]]
        model = association_config[:class_name].constantize
        attributes[key] = records.collect { |hash|
          topic = Topic.new(hash)
          hash = topic_to_record_attributes(topic, model)
          model.ffind_or_create(hash) }
      end
      attributes
    end

    def self.topic_hash_to_freebase_topic_record(topic_hash)
      hash = {
        :freebase_id => topic_hash["id"],
        :name => topic_hash["name"]
      }
      record = FreebaseTopic.find_or_create_by_freebase_id(hash)
    end
  end
end