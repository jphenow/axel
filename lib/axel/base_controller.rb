require 'axel/controller_helpers'
module Axel
  class BaseController < ControllerBase.new.configured
    include ControllerHelpers
  end
end
