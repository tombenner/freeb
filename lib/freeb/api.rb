require 'httparty'
require 'uri'
require 'json'

module Freeb
  class API
    @base_url = "https://www.googleapis.com/freebase/v1/"
    
    def self.get(id)
      mql = {
        "id" => id,
        "name" => nil
      }
      topic(mql)
    end

    def self.topic(mql)
      result = mqlread(mql)
      return nil if result.blank?
      Freeb::Topic.new(result)
    end

    def self.search(params)
      log "Search Request: #{params}"
      url = "#{@base_url}search?#{params.to_query}"
      result = get_result(url)
      log "Search Response: #{result}"
      result["result"].collect {|r| Topic.new(r) }
    end

    def self.mqlread(mql)
      log "MQL Request: #{mql}"
      query = URI.escape(mql.to_json)
      url = "#{@base_url}mqlread?query=#{query}"
      result = get_result(url)
      log "MQL Response: #{result}"
      return nil if result["result"].blank?
      result["result"]
    end

    def self.description(id)
      url = "#{@base_url}text#{id}"
      result = get_result(url)
      result["result"]
    end

    def self.get_result(url)
      response = HTTParty.get(url)
      if response.code == 200
        return JSON.parse(response.body)
      end
      raise ResponseException, "Freebase Response #{response.code}: #{JSON.parse(response.body).inspect}"
      nil
    end

    def self.log(message)
      Rails.logger.debug("Freeb: #{message}")
    end
  end
end