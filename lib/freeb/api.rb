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
      if result.is_a?(Array)
        result.collect { |r| Topic.new(r) }
      else
        Topic.new(result)
      end
    end

    def self.search(params)
      log "Search Request: #{params}"
      url = "#{@base_url}search"
      result = get_result(url, params)
      log "Search Response: #{result}"
      result["result"].collect { |r| Topic.new(r) }
    end

    def self.mqlread(mql)
      log "MQL Request: #{mql}"
      url = "#{@base_url}mqlread"
      result = get_result(url, :query => mql.to_json)
      log "MQL Response: #{result}"
      return nil if result["result"].blank?
      result["result"]
    end

    def self.description(id)
      url = "#{@base_url}text#{id}"
      result = get_result(url, nil)
      result["result"]
    end

    def self.get_result(url, params={})
      unless params.nil?
        params[:key] = Config.settings[:api_key] unless Config.settings[:api_key].blank?
        url = "#{url}?#{params.to_query}"
      end
      if Config.settings[:cache][:is_active]
        cache_key = cache_key_for_url(url)
        result = Rails.cache.read(cache_key)
        if result
          log "Read cache for #{url}"
          result
        else
          result = get_uncached_result(url)
          Rails.cache.write(cache_key, result, :expires_in => Config.settings[:cache][:expires_in])
          log "Wrote cache for #{url}"
          result
        end
      else
        get_uncached_result(url)
      end
    end

    def self.get_uncached_result(url)
      response = HTTParty.get(url)
      if response.code == 200
        return JSON.parse(response.body)
      end
      raise ResponseException, "Freebase Response #{response.code}: #{JSON.parse(response.body).inspect}"
      nil
    end

    private

    def self.cache_key_for_url(url)
      {:gem => "Freeb", :class => "API", :key => "get_result", :url => url}
    end

    def self.log(message)
      Rails.logger.debug("Freeb: #{message}")
    end
  end
end