require 'spec_helper'
module Axel
  module Payload
    describe Errors do
      subject { Errors.new params }
      let(:params) { {} }

      its(:messages) { should == [] }
      its(:status) { should == 200 }

      context "http created code" do
        let(:params) { { status: 201 } }
        it "should be success" do
          subject.success?.should be_truthy
          subject.display?.should be_falsey
        end
      end

      context "http accepted code" do
        let(:params) { { status: 202 } }
        it "should be success" do
          subject.success?.should be_truthy
          subject.display?.should be_falsey
        end
      end

      context "http no content code" do
        let(:params) { { status: 204 } }
        it "should be success" do
          subject.success?.should be_truthy
          subject.display?.should be_falsey
        end
      end

      context "exception" do
        let(:params) { { status: 404, messages: ["Fail!"] } }
        it "sets exception" do
          subject.exception.should be_a RemoteError
          subject.exception.to_s.should == "Failed. HTTP Status: 404, Messages: Fail!"
        end
      end

      context "reset!" do
        let(:params) { { status: 404, messages: ["Fail!"] } }

        it "sets params, resets, clear object" do
          subject.status_code.should == 404
          subject.messages.should == ["Fail!"]
          subject.reset!
          subject.status_code.should == 200
          subject.messages.should == []
        end
      end

      describe "header status" do
        its(:header_status) { should == 200 }
        context "non-200 status" do
          before do
            subject.status = :unprocessable_entity
          end

          its(:header_status) { should == 422 }

          context "suppressed" do
            let(:params) { { suppress_response_codes: 1 } }
            its(:header_status) { should == 200 }
          end
        end
      end

      describe "drops" do
        let(:params) { { messages: ["no good"], status: 404 } }

        context "with a drop" do
          it "changes the boolean and drops the message" do
            subject.drop?.should be_falsey
            subject.drop!
            subject.drop?.should be_truthy
            subject.display.should == {}
          end
        end

        context "without a drop" do
          its(:display) { should == { status: 404, messages: ["no good"] } }
        end
      end

      describe "<<" do
        it "adds to the error list" do
          expect { subject << "There was an error" }.to change { subject.messages }.from([]).to(["There was an error"])
        end
      end

      describe "display" do
        its(:display) { should == { status: 200, messages: [] } }

        context "with some errors and status" do
          before do
            subject << "ERROR"
            subject.status = :unprocessable_entity
          end

          its(:display) { should == { status: 422, messages: ["ERROR"] } }
        end
      end

      describe "display?" do
        its(:display?) { should == false }

        context "with a non 200 status" do
          before do
            subject.status = 403
          end
          its(:display?) { should == true }
        end

        context "with an error message" do
          before do
            subject << "ERROR"
          end
          its(:display?) { should == true }
        end
      end

      describe "new_error" do
        context "non-200 status, one message" do
          before do
            subject.new_error 404, "ERROR"
          end
          its(:display) { should == { status: 404, messages: ["ERROR"] } }
        end

        context "non-200 status, multiple messages" do
          before do
            subject.new_error :not_found, "ERROR", "ERROR 2"
          end
          its(:display) { should == { status: 404, messages: ["ERROR", "ERROR 2"] } }
        end

        context "200 status, multiple messages" do
          before do
            subject.new_error nil, "ERROR"
          end
          its(:display) { should == { status: 200, messages: ["ERROR"] } }
        end
      end

      describe "formats" do
        context "no display" do
          its(:to_json) { should == "" }
          its(:to_xml) { should == "" }
        end

        context "with errors and status" do
          before do
            subject.new_error :not_found, "Not found"
          end

          its(:to_json) { should == { status: 404, messages: ["Not found"] }.to_json }
          its(:to_xml) { should == { status: 404, messages: ["Not found"] }.to_xml(skip_instruct: true, root: :error) }
        end
      end
    end
  end
end
