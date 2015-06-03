module Axel
  class Router
    private
    attr_writer :path
    attr_writer :origin_klass
    attr_writer :method_name
    attr_writer :parameters
    attr_writer :options

    public
    attr_reader :path
    attr_reader :origin_klass
    attr_reader :method_name
    attr_reader :parameters
    attr_reader :options

    def initialize(klass, path, name, options = {})
      self.path = path.to_s
      self.origin_klass = klass
      self.method_name = name.to_s
      self.options = options || {}
      extract_parameters!
    end

    def define_route
      setup_klass_method
      self
    end

    def route(*args)
      route_path = build_path_with_args *args
      route_options = extract_routed_args_options args
      run_route route_path, route_options
    end

    # The class constant used for querying and dumping the
    # response to
    def klass
      klass_from_class_option || klass_from_class_name_option || origin_klass
    end
    private :klass

    def klass_from_class_option(class_option = options[:class])
      class_option.respond_to?(:querier) && class_option
    end
    private :klass_from_class_option

    def klass_from_class_name_option
      options[:class_name].present? &&
        klass_from_class_option(options[:class_name].to_s.camelize.safe_constantize)
    end
    private :klass_from_class_name_option

    def run_route(route_path, route_options)
      klass.querier.without_default_path.at_path(route_path).request_options route_options
    end
    private :run_route

    def extract_routed_args_options(args)
      hash_options = arity > 0 && args.first.is_a?(Hash)
      first_option = hash_options ? 1 : arity - 1
      args[first_option..-1].to_a.extract_options!
    end
    private :extract_routed_args_options

    # Sets up a new static method on the class that defines the
    # route. The method actually delegates to our router with the
    # method's name.
    def setup_klass_method
      origin_klass.define_singleton_method method_name do |*args|
        self.routes[__method__].route *args
      end
    end
    private :setup_klass_method

    def extract_parameters!
      if parameters.nil?
        self.parameters = path.
          split("/").
          select { |s| s.start_with?(":") }.
          map { |s| s[1..-1] }
      else
        true
      end
    end
    private :extract_parameters!

    def arity
      parameters.count
    end
    private :arity

    def build_path_with_args(*args)
      param_options = args.first.is_a?(Hash) ? handle_hash(args.first) : handle_splat(args)
      path.split("/").collect { |piece|
        piece.match(/^:/) ? param_options[piece.to_s[1..-1]] : piece
      }.join "/"
    end
    private :build_path_with_args

    def handle_hash(hash)
      hash = hash.with_indifferent_access
      parameters.collect { |param_name| { param_name => hash[param_name] } }.
        inject({}) { |new_hash, found| new_hash.merge found }.
        with_indifferent_access
    end
    private :handle_hash

    def handle_splat(splat)
      values = splat[0...arity].map(&:to_s)
      while values.size < arity do
        values << ""
      end
      Hash[parameters.zip(values)].
        with_indifferent_access
    end
    private :handle_splat
  end
end
