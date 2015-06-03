module Axel
  class ControllerBase
    def configured
      should_use_api? ? api_base : proper_base
    end

    def should_use_api?
      config.uses_rails_api? && !!api_base
    rescue NameError
      false
    end

    private

    def api_base
      ::ActionController::API
    end

    def proper_base
      ::ActionController::Base
    end

    def config
      Axel._config
    end
  end
end
