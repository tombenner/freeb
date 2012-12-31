module Freeb
  module Models
    module ClassMethods
      def freeb(&block)
        include InstanceMethods
        dsl = DSL.new
        dsl.instance_eval(&block)
        options = ModelConfig.register(self, dsl.config)

        accessible_attributes = [:freebase_id, :name]
        accessible_attributes += (options[:properties].merge(options[:topics]).merge(options[:has_many])).keys

        attr_reader :freeb_config
        attr_accessible *accessible_attributes
        validates_presence_of :freebase_id, :name
        
        initialize_topic_associations(options)
        initialize_has_many_associations(options)
        
        @freeb_config = ModelConfig.get(self)
      end

      def initialize_topic_associations(options)
        return if options[:topics].blank?
        options[:topics].each do |key, value|
          join_association = :"#{key}_freebase_topic_relations"
          has_many join_association, :as => :subject, :class_name => "FreebaseTopicRelation",
            :conditions => {:property => value[:id]}, :before_add => :"before_add_#{join_association}"
          define_method :"before_add_#{join_association}" do |record|
            record.property = value[:id]
          end
          has_many key, :through => join_association, :source => :freebase_topic
          join_association = :"freebase_topic_relations_#{key}"
          FreebaseTopic.has_many join_association, :class_name => "FreebaseTopicRelation",
            :conditions => {:property => value[:id]}
          FreebaseTopic.has_many self.name.tableize, :through => join_association,
            :source => :subject, :source_type => self.name
        end
      end

      def initialize_has_many_associations(options)
        return if options[:has_many].blank?
        options[:has_many].each do |key, association|
          # Two-sided polymorphic has_many relationships are supported by Rails, so we'll do this with a HABTM and
          # custom insert SQL. Is there a better approach?
          join_table = "freebase_model_relations"
          has_and_belongs_to_many key, :join_table => join_table,
            :foreign_key => "subject_id", :association_foreign_key => "object_id",
            :conditions => {
              "#{join_table}.subject_type" => self.name,
              "#{join_table}.object_type" => association[:class_name],
              "#{join_table}.property" => association[:id]
            },
            :insert_sql => proc { |object|
              %{INSERT INTO `#{join_table}`
                  (`subject_type`, `subject_id`, `property`, `object_type`, `object_id`)
                VALUES
                  ("#{self.class.name}", "#{id}", "#{association[:id]}", "#{association[:class_name]}", "#{object.id}" )}
            }
        end
      end

      def fnew(freebase_id)
        return nil if freebase_id.nil?
        return fnew_with_array(freebase_id) if freebase_id.is_a?(Array)
        topic = Converter.freebase_id_to_topic(freebase_id, self)
        new(Converter.topic_to_record_attributes(topic, self))
      end

      def fnew_by_name(name)
        return nil if name.nil?
        return names.collect { |name| fnew_by_name(name) } if name.is_a?(Array)
        topic = Converter.name_to_topic(name, self)
        new(Converter.topic_to_record_attributes(topic, self))
      end

      def fcreate(freebase_id)
        return nil if freebase_id.nil?
        return fcreate_with_array(freebase_id) if freebase_id.is_a?(Array)
        existing = find_by_freebase_id(freebase_id)
        return existing unless existing.blank?
        begin
          topic = Converter.freebase_id_to_topic(freebase_id, self)
        rescue ResponseException
          return nil
        end
        return nil if topic.blank?
        create(Converter.topic_to_record_attributes(topic, self))
      end

      def fcreate_by_name(name)
        return nil if name.nil?
        if name.is_a?(Array)
          names = name
          return names.collect { |name| fcreate_by_name(name) }
        end
        existing = find_by_name(name)
        return existing unless existing.blank?
        begin
          topic = Converter.name_to_topic(name, self)
        rescue ResponseException
          return nil
        end
        return nil if topic.blank?
        create(Converter.topic_to_record_attributes(topic, self))
      end

      def fcreate_all
        return fcreate([{}])
      end

      def ffind_or_create(hash)
        find_or_create_by_freebase_id(hash)
      end

      protected

      def fnew_with_array(array)
        if array.first.is_a?(String)
          freebase_ids = array
          freebase_ids.collect { |freebase_id| fnew(freebase_id) }
        elsif array.first.is_a?(Hash)
          fnew_with_mql(array)
        end
      end

      def fcreate_with_array(array)
        if array.first.is_a?(String)
          freebase_ids = array
          freebase_ids.collect { |freebase_id| fcreate(freebase_id) }
        elsif array.first.is_a?(Hash)
          fcreate_with_mql(array)
        end
      end

      def fnew_with_mql(mql)
        results = mql_to_results(mql)
        results.collect do |hash|
          topic = Topic.new(hash)
          new(Converter.topic_to_record_attributes(topic, self))
        end
      end

      def fcreate_with_mql(mql)
        results = mql_to_results(mql)
        results.collect do |hash|
          topic = Topic.new(hash)
          ffind_or_create(Converter.topic_to_record_attributes(topic, self))
        end
      end

      def mql_to_results(mql)
        mql[0] = mql[0].inject({}){|hash, (k,v)| hash[k.to_s] = v; hash}
        mql[0]["id"] = nil if mql[0]["id"].blank?
        mql[0]["name"] = nil if mql[0]["name"].blank?
        mql[0]["type"] = @freeb_config[:type] if mql[0]["type"].blank?
        API.mqlread(mql)
      end
    end

    module InstanceMethods
      def fupdate
        topic = Converter.freebase_id_to_topic(freebase_id, self)
        attributes = Converter.topic_to_record_attributes(topic, self)
        update_attributes(attributes)
      end

      def fimage(options={})
        url = "https://usercontent.googleapis.com/freebase/v1/image#{freebase_id}"
        url << "?#{options.to_query}" unless options.blank?
        url
      end
    end
  end
end
