module Axel
  class Uri < Typhoid::Uri
    def config
      (
        Axel._config.environment_uri_config || {}
      ).with_indifferent_access
    end

    def to(config_key, staging_number = nil)
      new_base = apply_suffix dashed_app_name,
        staging_number,
        config_for(config_key)[:host]
      base.host = new_base
      base.scheme = config_for(config_key)[:scheme]
      self
    end

    def app_name
      dashed_app_name.underscore.humanize.titleize
    end

    def dashed_app_name
      base.host.to_s.gsub(/\..*$/, "")
    end

    def config_for(config_key)
      config[config_key] || default_handler
    end
    private :config_for

    def default_handler
      config[:default] || { host: ".dev", scheme: "http" }
    end
    private :default_handler

    def apply_suffix(base_name, staging_number, config_handler)
      config_handler = convert_string_to_proc config_handler
      config_handler.call base_name, staging_number
    end
    private :apply_suffix

    def convert_string_to_proc(handler)
      handler.is_a?(Proc) ? handler : Proc.new { |base, n| "#{base}#{handler}" }
    end
    private :convert_string_to_proc
  end
end
