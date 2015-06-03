require 'spec_helper'
class Sport < Axel::ServiceResource::Base
  field :friendly_name
  field :status
end
module Axel
  module ServiceResource
    describe Sport do
      subject { Sport.new payload }

      let(:payload) { {} }

      its(:metadata) { should be_a Payload::Metadata }
      its(:remote_errors) { should be_a Payload::Errors }
      its(:result) { should == {} }

      describe "with some nested" do
        let(:payload) { { metadata: meta, errors: errors, result: result } }
        let(:meta) { nil }
        let(:errors) { nil }
        let(:result) { nil }

        its(:metadata) { should be_a Payload::Metadata }
        its(:remote_errors) { should be_a Payload::Errors }
        its(:result) { should == {} }

        describe "errorless" do
          let(:meta) { { current_user: { user_name: "jon" } } }
          let(:result) { { friendly_name: "Jon" } }

          its(:metadata) { should be_a Payload::Metadata }
          its(:remote_errors) { should be_a Payload::Errors }
          its(:result) { should == { "friendly_name" => "Jon" } }

          it "has data from meta" do
            subject.metadata[:current_user].should == { "user_name" => "jon" }
          end
        end

        describe "with errors" do
          let(:meta) { { current_user: { user_name: "jon" } } }
          let(:result) { { friendly_name: "Jon" } }
          let(:errors) { { status: 401 } }

          its(:metadata) { should be_a Payload::Metadata }
          its(:remote_errors) { should be_a Payload::Errors }
          its(:result) { should == { "friendly_name" => "Jon" } }

          it "has data from meta" do
            subject.metadata[:current_user].should == { "user_name" => "jon" }
          end

          it "has data from errors" do
            subject.remote_errors.status_code.should == 401
          end

          it "has attributes" do
            subject.friendly_name.should == "Jon"
          end
        end

        describe "with save" do
          let(:result) { { friendly_name: "Jon" } }
          before do
            Typhoeus::Request.stub post: double(body: { status: "Active" }.to_json, success?: true, code: 200)
            subject.stub save_request: double(request_uri: "", options: {})
          end

          it "doesn't lose its friendly name" do
            subject.friendly_name.should == "Jon"
            subject.save
            subject.remote_errors.status_code.should == 200
            subject.friendly_name.should == "Jon"
            subject.status.should == "Active"
          end
        end

        describe "with envelope save" do
          let(:result) { { friendly_name: "Jon" } }
          before do
            Typhoeus::Request.stub post: double(body: { metadata: {}, result: { status: "Active" } }.to_json, success?: true, code: 200)
            subject.stub save_request: double(request_uri: "", options: {})
          end

          it "doesn't lose its friendly name" do
            subject.friendly_name.should == "Jon"
            subject.save
            subject.remote_errors.status_code.should == 200
            subject.friendly_name.should == "Jon"
            subject.status.should == "Active"
          end
        end
      end
    end
  end
end
