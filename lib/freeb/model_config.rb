module Freeb
  class ModelConfig
    @models = {}
    
    def self.register(model, options)
      key = model_to_key(model)
      @models[key] = normalize_options(options)
    end

    def self.get(model)
      key = model_to_key(model)
      @models[key]
    end

    def self.get_query_properties(model)
      config = get(model)
      query_properties = {}
      raise "Empty Freeb config for #{model}" if config.blank?
      query_properties.merge!(config[:properties].inject({}) { |h, (k, property)| h[property[:id]] = nil; h })
      query_properties.delete("description")
      query_properties.merge!(config[:topics].inject({}) { |h, (k, topic)| h[topic[:id]] = [{:id => nil, :name => nil}]; h })
      query_properties.merge!(get_has_many_properties(model))
      query_properties
    end

    def self.get_has_many_properties(model)
      config = get(model)
      properties = {}
      config[:has_many].each do |key, association|
        association_class = association[:class_name].classify.constantize
        association_class_config = get(association_class)
        association_properties = {:id => nil, :name => nil}
        association_properties.merge!(get_query_properties(association_class))
        key = association[:id]
        properties[key] = [association_properties]
      end
      properties
    end

    def self.get_migration_properties(model)
      config = get(model)
      schema = Freeb.mqlread({
        :name => nil,
        :id => config[:type],
        :type => [{:id => "/type/type"}],
        "!/type/property/schema" => [{"/type/property/expected_type" => nil, "id" => nil, "name" => nil}]
      })
      property_types = {}
      schema["!/type/property/schema"].each do |property|
        property_types[property["id"]] = property["/type/property/expected_type"]
      end
      config[:properties].collect do |key, property|
        expected_type = property_types[property[:id]]
        type = case expected_type
        when "/type/boolean"
          :boolean
        when "/type/datetime"
          :datetime
        when "/type/float"
          :float
        when "/type/int"
          :integer
        when "/type/text"
          :text
        else
          :string
        end
        if property[:id] == "description"
          type = "text"
        end
        { :key => key, :type => type }
      end
    end

    def self.model_to_key(model)
      model.name.underscore.to_sym
    end

    def self.normalize_options(options)
      normalize_properties(options)
      normalize_topics(options)
      normalize_has_many(options)
      options
    end

    def self.normalize_properties(options)
      properties = {}
      options[:properties].flatten(1).each do |property|
        if property.is_a?(String)
          properties[property.to_sym] = {
            :key => property,
            :id => key_to_id(property, options)
          }
        elsif property.is_a?(Hash)
          property.each do |key, value|
            if value.is_a?(String)
              properties[key.to_sym] = {
                :key => value,
                :id => key_to_id(value, options)
              }
            elsif value.is_a?(Hash)
              defaults = {
                :key => key,
                :id => key_to_id(key, options)
              }
              properties[key.to_sym] = defaults.merge(value)
            end
          end
        end 
      end
      options[:properties] = properties
    end

    def self.normalize_topics(options)
      topics = {}
      options[:topics] = [options[:topics]] if !options[:topics].is_a?(Array)
      options[:topics].each do |topic|
        if topic.is_a?(String) || topic.is_a?(Symbol)
          topic = topic.to_s
          topics[topic.to_sym] = {
            :key => topic,
            :id => key_to_id(topic, options)
          }
        elsif topic.is_a?(Hash)
          topic.each do |key, value|
            topics[key.to_sym] = {
              :key => key,
              :id => key_to_id(value, options)
            }
          end
        end
      end
      options[:topics] = topics 
    end

    def self.normalize_has_many(options)
      associations = {}
      options[:has_many] = [options[:has_many]] if !options[:has_many].is_a?(Array)
      options[:has_many].each do |association|
        if association.is_a?(String) || association.is_a?(Symbol)
          association = association.to_s
          associations[association.to_sym] = {
            :key => association.to_sym,
            :id => key_to_id(value, options),
            :class_name => association.singularize.camelize
          }
        elsif association.is_a?(Hash)
          association.each do |key, value|
            key = key.to_s
            associations[key.to_sym] = {
              :key => key,
              :id => key_to_id(value, options),
              :class_name => key.singularize.camelize
            }
          end
        end
      end
      options[:has_many] = associations 
    end

    def self.key_to_id(key, options)
      key = key.to_s
      if key == "description"
        key
      elsif key[0,1] == "/"
        key
      else
        "#{options[:type]}/#{key}"
      end
    end
  end
end