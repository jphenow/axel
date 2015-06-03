module Axel
  RecordNotFound = Class.new StandardError
  module ControllerHelpers
    extend ActiveSupport::Concern
    included do
      if respond_to?(:helper_method)
        helper_method :errors,
          :metadata,
          :header_status,
          :drop_meta?,
          :format,
          :render_nil_format,
          :safe_json_load,
          :xml_clean
      end

      delegate :header_status,
        to: :errors

      if respond_to?(:layout) && !ControllerBase.new.should_use_api?
        layout "axel"
      end

      if respond_to?(:rescue_from)
        rescue_from ForceSSL do |e|
          drop_meta!
          rescue_error status: :forbidden, message: "SSL is required"
        end

        rescue_from NotAuthorized do |e|
          rescue_error status: 401, message: "User not authorized"
        end

        rescue_from Axel::RecordNotFound do |e|
          rescue_error status: 404, message: "Record not found"
        end

        if defined?(ActiveRecord::RecordNotFound)
          rescue_from ActiveRecord::RecordNotFound do |e|
            rescue_error status: 404, message: "Record not found"
          end
        end

        if defined?(ActiveModel::MassAssignmentSecurity::Error)
          rescue_from ActiveModel::MassAssignmentSecurity::Error do |e|
            rescue_error status: 422, message: "Unacceptable parameter being used"
          end
        end

        if defined?(ActionController::UnknownFormat)
          rescue_from ActionController::UnknownFormat do |e|
            render nothing: true, status: 406, message: "Unknown Format"
          end
        end
      end
    end

    module ClassMethods
      def respond_to_json_xml
        respond_to :json, :xml
      end
    end

    # Public: Quick access to a set of errors we're tracking
    # while dealing with a request
    #
    # Example:
    #
    #   errors
    #   # => <# Errors ...>
    #
    # Return an object for recording errors over a request
    def errors
      @errors ||= Payload::Errors.new
    end

    def metadata
      @metadata ||= Payload::Metadata.new
    end

    # Default API response when an error occurs
    def rescue_error(options = {})
      messages = ([options[:messages]] + [options[:message]]).flatten.compact
      errors.new_error options[:status], *messages
      respond_to_empty
    end

    # Public: Use for weird actions like #update where we don't want
    # to create a whole rabl template for it. This will allow the format
    # to fixed correctly and render a different action for you.
    #
    # action    - used to pick the template we're now rendering
    #
    # Example:
    #
    #   respond_with_action :show
    #
    def respond_with_action(action)
      respond_with do |f|
        f.json { render action: action }
        f.xml { render action: action }
      end
    end
    alias render_action respond_with_action

    # Public: Use to respond with an empty template. Especially useful for
    # manipulative controller actions where you don't want to have a new view,
    # but you DO want to return our "envelope"
    def respond_to_empty
      respond_to do |f|
        f.json { render nothing: true, layout: "axel", status: header_status }
        f.xml { render nothing: true, layout: "axel", status: header_status }
      end
    end
    alias render_empty respond_to_empty

    # Public: Use as a before filter. Will find a resource with some automation.
    # Find based on params.
    #
    # options   - Hash of options for tweaking
    #           :finder   - Column being used for the select (:id, :user_name)
    #           :value    - The value the column should be (an ID or Name value)
    #
    # Example:
    #
    #   PersonasController#find_resource # (with params[:id] => 1)
    #   # => @persona # => <# Persona id: 1 #>
    #
    #   PersonasController#find_resource(finder: :user_id) # (with params[:user_id] => 1)
    #   # => @persona # => <# Persona user_id: 1 #>
    #
    #   PersonasController#find_resource(finder: :user_id, value: 2) # (with params[:user_id] => 1)
    #   # => @persona # => <# Persona user_id: 2 #>
    #
    # Return the value of the instance variable we just set
    def find_resource(options = {})
      resource_name = controller_name.singularize
      resource = controller_name.classify.constantize
      finder_column = options[:finder] || :id
      finder_value = options[:value] || params[:id]
      resources = resource.where(finder_column => finder_value)
      if resources.length == 0
        raise RecordNotFound
      else
        instance_variable_set "@#{resource_name}", resources.first
      end
    end

    def query_params
      try_strong_params request.GET
    end

    def post_params
      try_strong_params request.POST
    end

    def object_params
      try_strong_params post_params.fetch(object_name, post_params)
    end

    def try_strong_params(regular_params)
      ControllerParameters.new(regular_params).params_object
    end

    def object_name
      controller_name.singularize
    end

    def force_ssl!
      return true unless Rails::Application.productionish?
      if !request.ssl?
        raise ForceSSL
      end
    end

    def drop_meta!
      metadata.drop!
    end

    def drop_meta?
      metadata.drop?
    end

    def format
      params[:format] || :json
    end

    def render_nil_format
      {
        json: nil,
        xml: ""
      }.with_indifferent_access[format]
    end

    def rabl_render(object, view)
      Rabl.render(object, view, view_path: 'app/views', scope: self)
    end

    def safe_json_load(json)
      json.present? ? MultiJson.load(json, mode: :null) : nil
    end

    def xml_clean(payload)
      payload.gsub(/\<(\/)*hash\>\s{1}/, '').
        gsub(/<\?\W*([xX][mM][lL])\W*version.*encoding.*\?>/, "").
        strip
    end
  end
end
