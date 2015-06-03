require 'spec_helper'
module Axel
  module Configurators
    describe Services do
      context "service adding" do
        before { subject.add_service :user_service, "http://user-service.dev" }

        it "sets up a service object" do
          subject.services[:user_service].should be_a Configurations::Service
        end
      end

      context "resource adding" do
        context "without service pre-created" do
          before { subject.add_resource :boss_service, :boss, service: { url: "http://boss-service.dev" } }

          it "sets up a resource" do
            subject.services[:boss_service].should be_a Configurations::Service
            subject.resources[:boss].should be_a Configurations::Resource
          end
        end

        context "with service pre-created" do
          before do
            subject.add_service :user_service, "http://user-service.dev"
            subject.add_resource :user_service, :user
          end

          it "sets up a resource" do
            subject.services[:user_service].should be_a Configurations::Service
            subject.resources[:user].should be_a Configurations::Resource
          end
        end
      end
    end
  end
end
