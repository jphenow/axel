require 'spec_helper'
module Axel::Associations
  describe HasOne do
    let(:instance) { User.new id: 1 }
    let(:options) { {} }
    subject { instance.class.send(:has_one_associations)[:address] }

    before do
      subject.send :options=, options
    end

    its(:build_klass) { should be Address }

    it "tries to get a user with options" do
      Address.should_receive(:querier).and_return(Address)
      Address.should_receive(:without_default_path).and_return(Address)
      Address.should_receive(:at_path).with("/users/1/address").and_return(Address)
      Address.should_receive(:request_options).with({}).and_return([])

      instance.address
    end
  end
end
