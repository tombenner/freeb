require 'active_support/core_ext/numeric'

module Freeb
  class Config
    class << self
      attr_reader :settings
    end

    @settings = {
      :api_key => nil,
      :cache => {
        :is_active => true,
        :expires_in => 1.day
      }
    }

    def self.api_key(api_key)
      @settings[:api_key] = api_key
    end

    def self.cache(options)
      @settings[:cache].merge!(options)
    end
  end
end