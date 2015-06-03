require 'spec_helper'
module Axel::Associations
  describe Base do
    let(:model) { User }
    let(:relation_name) { "personas" }
    let(:options) { {} }
    let(:instance) { User.new }
    subject { described_class.new model, relation_name, options }

    it "handles a read" do
      subject.handles_method?(:personas).should be_truthy
    end

    it "doesn't handle a write" do
      subject.handles_method?(:personas=).should be_falsey
    end

    it "runs a getter" do
      subject.should_receive(:getter).and_return nil
      subject.run_method(instance, :personas)
    end

    it "runs a getter" do
      expect { subject.run_method(instance, :personas=) }.to raise_error NoMethodError,
        "Could not find an association method for `personas='"
    end
  end
end
