require 'spec_helper'

# So we don't have to add rails-api as a dependency
ActionController::API = ActionController::Base
module Axel
  describe ControllerBase do
    its(:configured) { should == ::ActionController::Base }
    context "configured to use rails api" do
      before do
        subject.send(:config).stub uses_rails_api?: true
      end

      its(:configured) { should == ActionController::API }
    end
  end
end
