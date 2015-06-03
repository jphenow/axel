require 'spec_helper'
Axel::SomeClass = Class.new Axel::ServiceResource::Base
module Axel
  module ServiceResource
    describe Builder do
      let(:klass) { SomeClass }
      let(:success) { true }
      let(:code) { 200 }
      let(:response_stub) { double "Response", body: body_stub_hash.to_json, code: code, success?: success }
      let(:bare_body) { { id: "1", name: "jon" } }

      subject { Builder.new klass, response_stub }

      describe "singular non-evelope" do
        let(:body_stub_hash) { bare_body }

        its(:enveloped?) { should be_falsey }
        its(:result) { should == bare_body.stringify_keys }
        its(:errors) { should == nil }
        its(:metadata) { should == nil }
        its(:array?) { should be_falsey }
        its(:build) { should be_a SomeClass }
      end

      describe "multi non-evelope" do
        let(:body_stub_hash) { [bare_body] }

        its(:enveloped?) { should be_falsey }
        its(:result) { should == [bare_body.stringify_keys] }
        its(:errors) { should == nil }
        its(:metadata) { should == nil }
        its(:array?) { should be_truthy }
        its(:build) { should have(1).some_classes }
      end

      describe "envelope" do
        let(:metadata) { { "current_user" => { "id" => 1, "user_name" => "jon" } } }
        let(:errors) { nil }
        let(:body_stub_hash) { { metadata: metadata, result: result } }
        describe "singular" do
          let(:result) { bare_body }

          its(:enveloped?) { should be_truthy }
          its(:result) { should == bare_body.stringify_keys }
          its(:errors) { should == nil }
          its(:metadata) { should == metadata }
          its(:array?) { should be_falsey }
          its(:build) { should be_a SomeClass }
        end

        describe "multi" do
          let(:result) { [bare_body] }

          its(:enveloped?) { should be_truthy }
          its(:result) { should == [bare_body.stringify_keys] }
          its(:errors) { should == nil }
          its(:metadata) { should == metadata }
          its(:array?) { should be_truthy }
          its(:build) { should have(1).some_classes }
        end
      end
    end
  end
end
