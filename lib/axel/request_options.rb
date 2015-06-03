require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/hash/deep_merge'
module Axel
  class RequestOptions
    attr_accessor :given_options
    attr_accessor :default_options

    def initialize(default_options = {}, given_options)
      self.default_options = (default_options || {})
      self.given_options = (given_options || {}).with_indifferent_access
    end

    def compiled
      default_request_options.
        dup.
        deep_merge!(default_options).
        deep_merge!(given_options).
        with_indifferent_access
    end

    def default_request_options
      { headers: { 'Content-Type' => 'application/json' } }.with_indifferent_access
    end
    private :default_request_options
  end
end
