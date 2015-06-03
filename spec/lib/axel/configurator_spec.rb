require 'spec_helper'
module Axel
  describe Configurator do
    its(:services) { should be_a Configurators::Services }

    it "adds a proxy url" do
      subject.set_proxy_url "http://some-proxy-url"
      subject.proxy.should be_an ApiProxy
    end

    it "adds a new service" do
      subject.add_service "new_service", "http://new-service"
      subject.service_configs[:new_service].url.should == "http://new-service"
    end

    its(:uses_rails_api?) { should be_falsey }

    context "rails api set" do
      it "uses_rails_api?" do
        subject.uses_rails_api = true
        subject.uses_rails_api?.should be_truthy
        subject.uses_rails_api = false
      end
    end
  end
end
