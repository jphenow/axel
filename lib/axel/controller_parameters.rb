module Axel
  class ControllerParameters
    private
    attr_accessor :controller_params

    public

    def initialize(controller_params)
      self.controller_params = controller_params
    end

    def params_object
      strong_params? ? params_class.new(controller_params) : controller_params
    end

    def params_class # testability
      ActionController::Parameters
    end
    private :params_class

    def strong_module
      ActionController::StrongParameters
    end

    def strong_params?
      !!(params_class && strong_module)
    rescue
      false
    end
    private :strong_params?
  end
end
