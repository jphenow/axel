require 'axel/configurators/services'
module Axel
  class Configurator
    private
    attr_writer :services
    attr_writer :proxy
    attr_writer :environment

    public
    attr_reader :services
    attr_reader :proxy
    attr_reader :environment
    attr_writer :uses_rails_api
    attr_reader :proxy_request_options
    attr_accessor :environment_uri_config

    def initialize
      self.services = Configurators::Services.new
    end

    def service_configs
      services.services
    end

    def resources
      services.resources
    end

    def setup_proxy(url, request_options = {})
      self.proxy = ApiProxy.new url, request_options
      proxy.register!
    end

    def set_environment(name, stage_number = nil)
      self.environment = [name, stage_number]
    end

    def manual_environment_set?
      self.environment.present?
    end

    def add_service(service_name, url)
      services.add_service service_name, url
    end

    def add_resource(service_name, resource_name, options = {})
      services.add_resource service_name, resource_name, options
    end

    def uses_rails_api?
      !!@uses_rails_api
    end
  end
end
