require 'rails/generators'
require 'rails/generators/migration'

module Freeb
  class MigrationGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
    argument :model_name, :type => :string

    def self.next_migration_number(dirname="db/migrate")
      if ActiveRecord::Base.timestamped_migrations
        Time.new.utc.strftime("%Y%m%d%H%M%S")
      else
        "%.3d" % (current_migration_number(dirname) + 1)
      end
    end

    def create_migration_file
      @migration_class_name = "Create#{model_name.pluralize}"
      @table_name = model_name.tableize
      @properties = Freeb::Config.get_migration_properties(model_name.classify.constantize)
      template 'migration.rb', "db/migrate/#{self.class.next_migration_number}_create_#{@table_name}.rb"
    end
  end
end