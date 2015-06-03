require 'spec_helper'
module Axel
  module ServiceResource
    describe PayloadParser do
      subject { PayloadParser.new payload }
      let(:empty_wia) { {}.with_indifferent_access }
      let(:payload) { nil }
      let(:parsed) { subject.parsed }

      it "has a valid parsed" do
        parsed.first.should == empty_wia
        parsed[1].should == empty_wia
        parsed[2].should be_a Payload::Metadata
        parsed.last.should be_a Payload::Errors
      end

      describe "not-enveloped" do
        let(:result) { { name: "Jon" }.with_indifferent_access }
        let(:payload) { result }

        it "has a valid parsed" do
          parsed.first.should == payload
          parsed[1].should == result
          parsed[2].should be_a Payload::Metadata
          parsed.last.should be_a Payload::Errors
        end
      end

      describe "enveloped" do
        let(:metadata) { { current_user: { id: 1 } }.with_indifferent_access }
        let(:result) { { name: "Jon" }.with_indifferent_access }
        let(:errors) { { status: 200, messages: ["Success"] }.with_indifferent_access }
        let(:payload) { { metadata: metadata, result: result, errors: errors }.with_indifferent_access }

        it "has a valid parsed" do
          parsed.first.should == payload
          parsed[1].should == result
          parsed[2].should be_a Payload::Metadata
          parsed[2].attributes.should == metadata
          parsed.last.should be_a Payload::Errors
          parsed.last.attributes.should == errors
        end

        describe "array errors" do
          let(:payload) { { metadata: metadata, result: result, errors: errors }.with_indifferent_access }
          let(:errors) { ["Success"] }

          it "has a valid parsed" do
            parsed.first.should == payload
            parsed[1].should == result
            parsed[2].should be_a Payload::Metadata
            parsed[2].attributes.should == metadata
            parsed.last.should be_a Payload::Errors
            parsed.last.attributes.should == { "messages" => errors, "status" => 200 }
          end
        end
      end
    end
  end
end
