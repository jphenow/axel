require 'rabl'
require 'jbuilder'
require 'oj'
require 'typhoid'
require "axel/version"
require 'axel/controller_base'
require "axel/inspector"
require "axel/request_options"
require 'axel/uri'
require 'axel/controller_parameters'
require 'axel/cascadable_attribute'
require 'axel/application_extensions'
require 'axel/configurator'
require 'axel/payload/remote_error'

module Axel
  NotAuthorized = Class.new(StandardError)
  ForceSSL = Class.new(StandardError)

  def self.config(&block)
    yield _config
    _config.service_configs.each do |name, configuration|
      unless respond_to? name
        define_singleton_method(name) { configuration }
      end
    end
  end

  def self.service_configurator
    _config.services
  end

  def self.services
    _config.service_configs
  end

  def self.resources
    _config.resources
  end

  def self.environment
    _config.environment
  end

  def self.manual_environment_set?
    _config.manual_environment_set?
  end

  def self._config
    @config ||= Axel::Configurator.new
  end
end
require 'axel/application_helper'
require "axel/engine"
require 'axel/controller_helpers'
require 'axel/base_controller'
