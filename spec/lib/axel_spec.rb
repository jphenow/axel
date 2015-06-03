require 'spec_helper'
describe Axel do
  subject { Axel }

  context "services" do
    it { subject.service_configurator.should be_a Axel::Configurators::Services }
  end

  context "config" do
    context "with stubs" do
      context "block checks" do
        context "with block" do
          specify do
            expect { |b| subject.config &b }.to yield_with_args
          end
        end
      end
    end

    context "once" do
      before do
        subject.config do |config|
          config.add_resource :user_service, :user, service: { url: "http://user-service.dev" }
        end
      end

      it "sets a user service with a configuration" do
        subject.services[:user_service].should be_a Axel::Configurations::Service
      end

      it "sets a resource configuration" do
        subject.resources[:user].should be_a Axel::Configurations::Resource
      end

      context "twice" do
        before do
          subject.config do |config|
            config.add_resource :api_proxy, :registry, service: { url: "http://api-proxy.dev" }
            config.add_resource :user_service, :persona
          end
        end
        it "sets a user service with a configuration" do
          subject.services[:user_service].should be_a Axel::Configurations::Service
        end

        it "sets a user resource configuration" do
          subject.resources[:user].should be_a Axel::Configurations::Resource
        end

        it "sets a persona resource configuration" do
          subject.resources[:persona].should be_a Axel::Configurations::Resource
        end

        it "sets a api proxy service with a configuration" do
          subject.services[:api_proxy].should be_a Axel::Configurations::Service
        end

        it "sets a pers resource configuration" do
          subject.resources[:registry].should be_a Axel::Configurations::Resource
        end
      end
    end
  end
end
