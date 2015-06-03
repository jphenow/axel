require 'rails/application'
require 'active_support/concern'
module Axel
  module ApplicationExtensions
    extend ActiveSupport::Concern
    module ClassMethods
      def productionish?
        !!Rails.env.match(/(production|staging)/)
      end
    end
  end
end
Rails::Application.send :include, Axel::ApplicationExtensions
