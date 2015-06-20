require 'spec_helper'
require 'sequel'

describe Sequel::Plugins::Wisper do
  before(:all) do
    DB = Sequel.sqlite

    class ::Foo < Sequel::Model
      plugin :wisper
      plugin :schema
      plugin :validation_helpers

      set_schema do
        primary_key :id
        String :value
      end

      def validate
        super
        validates_presence :value
      end
    end

    Foo.create_table!
  end

  let(:hook_events) { [ :before_validation,
                        :after_validation,
                        :before_save,
                        :after_save,
                        :before_create,
                        :after_create,
                        :before_update,
                        :after_update,
                        :before_destroy,
                        :after_destroy,
                        :after_commit,
                        :after_rollback,
                        :after_destroy_commit,
                        :after_destroy_rollback ] }

  let(:all_events) { hook_events + [ :create_foo_successful,
                                     :create_foo_failed,
                                     :update_foo_successful,
                                     :update_foo_failed,
                                     :destroy_foo_successful,
                                     :destroy_foo_failed ] }

  before do
    @m = Foo.new
    @events = []
    all_events.each { |ev| @m.on(ev) { |m| @events << ev } }
  end

  describe 'on validation' do
    it 'broadcasts on #before_validation and #after_validation hooks' do
      expect(@m.valid?).to be false
      expect(@events).to eq([:before_validation, :after_validation])
    end
  end

  describe 'when Foo is created successfully' do
    before do
      @m.value = :foo
    end

    it 'broadcasts :create_foo_successful' do
      expect { @m.save }.to broadcast(:create_foo_successful, @m)
    end

    it 'broadcasts all model hook events in the expected order' do
      @m.save

      expected_events = [ :before_validation,
                          :after_validation,
                          :before_save,
                          :before_create,
                          :after_create,
                          :after_save,
                          :create_foo_successful,
                          :after_commit ]

      expect(@events).to eq(expected_events)
    end
  end

  describe 'when Foo fails to create' do
    before do
      @m.value = nil
    end

    it 'broadcasts :create_foo_failed' do
      expect {
        @m.save rescue Sequel::ValidationFailed
      }.to broadcast(:create_foo_failed, @m)
    end

    it 'broadcasts all model hook events in the expected order' do
      @m.save rescue Sequel::ValidationFailed

      expected_events = [ :before_validation,
                          :after_validation,
                          :create_foo_failed ]

      expect(@events).to eq(expected_events)
    end
  end

  describe 'when Foo is updated successfully' do
    before do
      @m.value = :foo
      @m.save
      @events.clear
      @m.value = :bar
    end

    it 'broadcasts :update_foo_successful' do
      expect { @m.save }.to broadcast(:update_foo_successful, @m)
    end

    it 'broadcasts all model hook events in the expected order' do
      @m.save

      expected_events = [ :before_validation,
                          :after_validation,
                          :before_save,
                          :before_update,
                          :after_update,
                          :after_save,
                          :update_foo_successful,
                          :after_commit ]

      expect(@events).to eq(expected_events)
    end
  end

  describe 'when Foo fails to update' do
    before do
      @m.value = :foo
      @m.save
      @events.clear
      @m.value = nil
    end

    it 'broadcasts :update_foo_failed' do
      expect {
        @m.save rescue Sequel::ValidationFailed
      }.to broadcast(:update_foo_failed, @m)
    end

    it 'broadcasts all model hook events in the expected order' do
      @m.save rescue Sequel::ValidationFailed

      expected_events = [ :before_validation,
                          :after_validation,
                          :update_foo_failed ]

      expect(@events).to eq(expected_events)
    end
  end

  describe 'when Foo is destroyed successfully' do
    before do
      @m.value = :foo
      @m.save
      @events.clear
    end

    it 'broadcasts :destroy_foo_successful' do
      expect { @m.destroy }.to broadcast(:destroy_foo_successful, @m)
    end

    it 'broadcasts all model hook events in the expected order' do
      @m.destroy

      expected_events = [ :before_destroy,
                          :after_destroy,
                          :after_destroy_commit,
                          :destroy_foo_successful ]

      expect(@events).to eq(expected_events)
    end
  end

  describe 'when Foo fails to destroy' do
    it 'broadcasts :destroy_foo_failed' do
      expect {
        @m.destroy rescue Sequel::NoExistingObject
      }.to broadcast(:destroy_foo_failed, @m)
    end

    it 'broadcasts all model hook events in the expected order' do
      @m.destroy rescue Sequel::NoExistingObject

      expected_events = [ :before_destroy,
                          :after_destroy_rollback,
                          :destroy_foo_failed ]

      expect(@events).to eq(expected_events)
    end
  end

  describe 'when Foo is created on a transaction, but is then rollbacked' do
    before do
      @m.value = :foo
    end

    it 'broadcasts :create_foo_failed' do
      expect { DB.transaction { @m.save; raise Sequel::Rollback } }
        .to broadcast(:create_foo_failed, @m)
    end

    it 'broadcasts all model hook events in the expected order' do
      DB.transaction do
        @m.save
        raise Sequel::Rollback
      end

      expected_events = [ :before_validation,
                          :after_validation,
                          :before_save,
                          :before_create,
                          :after_create,
                          :after_save,
                          :after_rollback,
                          :create_foo_failed ]

      expect(@events).to eq(expected_events)
    end
  end

  describe 'when Foo is updated on a transaction, but is then rollbacked' do
    before do
      @m.value = :foo
      @m.save
      @events.clear
      @m.value = :bar
    end

    it 'broadcasts :create_foo_failed' do
      expect { DB.transaction { @m.save; raise Sequel::Rollback } }
        .to broadcast(:update_foo_failed, @m)
    end

    it 'broadcasts all model hook events in the expected order' do
      DB.transaction do
        @m.save
        raise Sequel::Rollback
      end

      expected_events = [ :before_validation,
                          :after_validation,
                          :before_save,
                          :before_update,
                          :after_update,
                          :after_save,
                          :after_rollback,
                          :update_foo_failed ]


      expect(@events).to eq(expected_events)
    end
  end

  describe 'when Foo is destroyed on a transaction, but is then rollbacked' do
    before do
      @m.value = :foo
      @m.save
      @events.clear
    end

    it 'broadcasts :create_foo_failed' do
      expect { DB.transaction { @m.destroy; raise Sequel::Rollback } }
        .to broadcast(:destroy_foo_failed, @m)
    end

    it 'broadcasts all model hook events in the expected order' do
      DB.transaction do
        @m.destroy
        raise Sequel::Rollback
      end

      expected_events = [ :before_destroy,
                          :after_destroy,
                          :after_destroy_rollback,
                          :destroy_foo_failed ]

      expect(@events).to eq(expected_events)
    end
  end
end
