require 'spec_helper'

module Axel
  describe ControllerParameters do
    subject { ControllerParameters.new original_params }
    let(:original_params) { {} }
    let(:params_class) { double }
    it { should respond_to :params_object }

    describe "with strong params defined" do
      before do
        subject.stub strong_params?: true, params_class: params_class
      end

      it "creates strong params" do
        params_class.should_receive(:new).with(original_params).once
        subject.params_object
      end
    end

    describe "without strong params defined" do
      before do
        subject.stub strong_params?: false
      end

      it "returns the original object" do
        subject.params_object.should be original_params
      end
    end
  end
end
