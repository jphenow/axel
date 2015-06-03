module Axel
  class ApiProxy < ServiceResource::Base
    attr_reader :endpoint
    attr_reader :services
    attr_reader :request_options

    def self.cache_file
      cache_dir.join("api_registry_cache.json")
    end

    def self.cache_dir
      Rails.root.join("cache")
    end

    def self.build(_, response)
      if response.success?
        MultiJson.load(response.body)
      else
        {}
      end
    rescue MultiJson::DecodeError
      {}
    end

    def initialize(endpoint, request_options = {})
      @endpoint = endpoint
      @request_options = {}
    end

    def register!
      resource_settings.each do |resource_setting|
        Axel.config do |config|
          config.add_resource extract_service_name(resource_setting["service"]),
            extract_resource_name(resource_setting["path"]),
            service: { url: resource_setting["service"] }
        end
      end
    end

    def make_cache
      Dir.exists?(self.class.cache_dir) ? true : Dir.mkdir(self.class.cache_dir)
    end
    private :make_cache

    def write_cache(to_cache)
      make_cache
      File.open(self.class.cache_file, 'w') { |file| file.write to_cache.to_json }
      to_cache
    end
    private :write_cache

    def open_json(string_data)
      begin
        MultiJson.load string_data
      rescue MultiJson::DecodeError
        []
      end
    end
    private :open_json

    def read_cache
      File.exists?(self.class.cache_file) ? open_json(File.open(self.class.cache_file).read) : []
    end
    private :read_cache

    def resource_settings
      fresh = self.class.request(endpoint, "/registry.json", request_options)
      if fresh.has_key? "routes"
        write_cache fresh["routes"]
      else
        read_cache
      end
    end
    private :resource_settings

    def extract_service_name(service_url)
      service_url.gsub(/http[s]*\:\/\//,"").gsub(/\..*$/, "").underscore
    end
    private :extract_service_name

    def extract_resource_name(resource_path)
      resource_path.gsub(/^\//, "")
    end
    private :extract_resource_name
  end
end
