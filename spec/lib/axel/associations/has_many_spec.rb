require 'spec_helper'
module Axel::Associations
  describe HasMany do
    let(:instance) { User.new id: 1 }
    let(:options) { {} }
    subject { User.send(:has_many_associations)[:personas] }

    before do
      subject.send :options=, options
    end

    its(:build_klass) { should be Persona }

    it "tries to get a user with options" do
      Persona.should_receive(:querier).and_return(Persona)
      Persona.should_receive(:without_default_path).and_return(Persona)
      Persona.should_receive(:at_path).with("/users/1/personas").and_return(Persona)
      Persona.should_receive(:request_options).with({}).and_return([])

      instance.personas
    end
  end
end
