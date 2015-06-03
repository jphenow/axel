require 'spec_helper'
module Axel
  module Configurations
    describe Service do
      subject { Service.new name, url }
      let(:name) { :user_service }
      let(:url) { "http://user-service.dev" }

      describe "without resource" do
        its(:resources) { should == {} }
      end

      describe "with resources set" do
        before do
          subject.add_resource :user
          subject.add_resource :persona
        end

        its(:resources) { should have_key :user }
        it "user is a resource" do
          subject.resources[:user].should be_a Resource
        end

        its(:resources) { should have_key :persona }
        it "persona is a resource" do
          subject.resources[:persona].should be_a Resource
        end
      end
    end
  end
end
