module Axel
  class Querier
    private
    attr_writer :klass
    attr_writer :loaded
    attr_reader :records

    protected
    attr_accessor :where_values
    attr_accessor :manual_uri
    attr_accessor :extra_paths
    attr_accessor :request_option_values
    attr_accessor :paged
    attr_writer :records

    public
    attr_reader :klass
    attr_reader :loaded

    alias loaded? loaded
    alias paged? paged

    def self.query_methods
      [
        :all,
        :none,
        :where,
        :uri,
        :to_a,
        :at_path,
        :request_options,
        :without_default_path,
        :paged
      ]
    end

    def initialize(klass)
      self.klass = klass
      self.records = []
      self.extra_paths = []
      self.loaded = false
      self.where_values = {}.with_indifferent_access
      self.request_option_values = {}.with_indifferent_access
    end

    def paged
      query = clone
      query.paged = true
      query
    end

    def at_path(*paths)
      return self if paths.blank?
      query = clone
      query.extra_paths += paths
      query
    end

    # "http://user-service.dev"
    def uri(base_url)
      return self if base_url.blank?
      query = clone
      query.manual_uri = base_url.to_s
      query
    end

    def where(params = {})
      return self if params.blank? || !params.is_a?(Hash)
      query = clone
      query.request_option_values.deep_merge! params: params
      query
    end

    def request_options(params = {})
      return self if params.blank? || !params.is_a?(Hash)
      query = clone
      query.request_option_values.deep_merge! params
      query
    end
    alias_method :all, :request_options

    def none
      query = clone
      query.loaded!
      query.records = []
      query
    end

    def without_default_path
      query = clone
      query.manual_uri = klass.site
      query
    end

    def reload
      reset
      self
    end

    def to_a
      Array(loaded? ? records : self.records = run_requests)
    end

    def inspect
      to_a.inspect
    end

    def loaded!
      self.loaded = true
    end
    protected :loaded!

    def reset
      self.loaded = false
      self.records = []
      self
    end
    private :reset

    def request_uri
      Uri.new((manual_uri || klass.request_uri), *extra_paths).to_s
    end
    private :request_uri

    def retrieve_request_options
      klass.retrieve_default_request_options request_option_values
    end
    private :retrieve_request_options

    def run_requests
      loaded!
      execute_request_on_klass
    end
    private :run_requests

    def execute_request_on_klass
      initial = klass.request(request_uri, retrieve_request_options)
      return initial unless paged?

      single = initial.first
      return initial if single.blank? || !single.paged?

      (2..single.total_pages).reduce(initial) do |memo, page|
        paged_options = retrieve_request_options
          .stringify_keys
          .deep_merge "params" => { "page" => page }
        memo + klass.request(request_uri, paged_options)
      end
    end
    private :execute_request_on_klass

    def respond_to?(method, include_private = false)
      super || Array.public_method_defined?(method) || klass.routes.has_key?(method)
    end

    def method_missing(method, *args, &block)
      if Array.method_defined?(method)
        to_a.public_send(method, *args, &block)
      elsif klass.routes.has_key? method
        klass.public_send method, *args
      else
        super
      end
    end
  end
end
