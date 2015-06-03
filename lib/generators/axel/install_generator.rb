module Axel
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)
      desc "Creates a Axel initializer."

      def copy_initializer
        template "axel.rb", "config/initializers/axel.rb"
      end

      def show_readme
        readme "README.md" if behavior == :invoke
      end
    end
  end
end
