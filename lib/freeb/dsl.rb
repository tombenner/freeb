module Freeb
  class DSL
    attr_reader :config

    def initialize
      @config = {}
    end

    def type(value)
      @config[:type] = value
    end

    def properties(*args)
      @config[:properties] = args
    end

    def topics(*args)
      @config[:topics] = args
    end

    def has_many(*args)
      @config[:has_many] = args
    end
  end
end