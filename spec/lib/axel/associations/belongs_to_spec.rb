require 'spec_helper'
module Axel::Associations
  describe BelongsTo do
    let(:instance) { Persona.new id: 1, user_id: 2 }
    let(:options) { {} }
    let(:association_object) { Persona.send(:belongs_to_associations)[:user] }
    before do
      association_object.send :options=, options
    end

    describe "included in result" do
      let(:options) { { included: true } }
      subject { instance }

      it "does not get a user" do
        expect(subject.user).to be_nil
      end

      describe "with data present in result" do
        let(:instance) { Persona.new id: 1, user: { id: 1, name: "Jon" } }

        it "does not get a user" do
          expect(subject.user).to be_a User
        end
      end
    end

    describe "via API" do
      subject { association_object }
      its(:build_klass) { should be User }
      it "tries to get user" do
        User.should_receive(:find).with(2, {})
        instance.user
      end

      describe "use another ID method" do
        let(:options) { { id_attribute: :id } }

        it "tries to get a user with options" do
          User.should_receive(:find).with(1, {})

          instance.user
        end
      end

      describe "nested find" do
        let(:options) { { find_nested: true } }

        its(:find_nested?) { should be_truthy }

        it "tries to get a user with options" do
          User.should_receive(:querier).and_return(User)
          User.should_receive(:without_default_path).and_return(User)
          User.should_receive(:at_path).with("/personas/1/users/2").and_return(User)
          User.should_receive(:request_options).with({}).and_return([])

          instance.user
        end
      end
    end
  end
end
