module Axel
  class Engine < ::Rails::Engine
    if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR > 0
      isolate_namespace Axel
    end
    config.railties_order = [self, :main_app, :all]

    initializer 'axel.application_helper' do |app|
      ActiveSupport.on_load :action_controller do
        helper Axel::ApplicationHelper
      end
    end
  end
end
