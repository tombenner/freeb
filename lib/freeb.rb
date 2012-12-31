module Freeb
  def self.config
    yield Freeb::Config
  end

  def self.get(freebase_id)
    API.get(freebase_id)
  end

  def self.search(params)
    API.search(params)
  end

  def self.topic(mql)
    API.topic(mql)
  end

  def self.mqlread(mql)
    API.mqlread(mql)
  end
end

directory = File.dirname(File.absolute_path(__FILE__))
Dir.glob("#{directory}/freeb/*.rb") { |file| require file }
Dir.glob("#{directory}/generators/freeb/*.rb") { |file| require file }
Dir.glob("#{directory}/../app/models/*.rb") { |file| require file }

ActiveRecord::Base.extend Freeb::Models::ClassMethods