require 'spec_helper'
module Axel
  module Configurations
    describe Resource do
      subject { Resource.new name, service }
      let(:service) { Service.new(:user_service, "http://localhost") }
      let(:name) { :users }

      its(:name) { should == "user" }
      its(:base_url) { should == "http://localhost" }
      its(:path) { should == "users" }
      its(:full_url) { should == "http://localhost/users" }
    end
  end
end
