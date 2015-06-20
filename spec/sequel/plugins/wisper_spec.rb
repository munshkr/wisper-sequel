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

  before do
    @m = Foo.new
  end

  describe 'on validation' do
    it 'broadcasts on #before_validation and #after_validation hooks' do
      events = []
      @m.on(:before_validation) { events << :before_validation }
      @m.on(:after_validation) { events << :after_validation }

      expect(@m.valid?).to be false
      expect(events).to eq([:before_validation, :after_validation])
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
      expected_events = [ :before_validation,
                          :after_validation,
                          :before_save,
                          :before_create,
                          :after_create,
                          :create_foo_successful,
                          :after_save,
                          :after_commit ]

      events = []
      expected_events.each { |ev| @m.on(ev) { |m| events << ev } }

      @m.save
      expect(events).to eq(expected_events)
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
      expected_events = [ :before_validation,
                          :after_validation,
                          :create_foo_failed ]

      events = []
      expected_events.each { |ev| @m.on(ev) { |m| events << ev } }

      @m.save rescue Sequel::ValidationFailed
      expect(events).to eq(expected_events)
    end
  end

  describe 'when Foo is updated successfully' do
    before do
      @m.value = :foo
      @m.save
      @m.value = :bar
    end

    it 'broadcasts :update_foo_successful' do
      expect { @m.save }.to broadcast(:update_foo_successful, @m)
    end

    it 'broadcasts all model hook events in the expected order' do
      expected_events = [ :before_validation,
                          :after_validation,
                          :before_save,
                          :before_update,
                          :after_update,
                          :update_foo_successful,
                          :after_save,
                          :after_commit ]

      events = []
      expected_events.each { |ev| @m.on(ev) { |m| events << ev } }

      @m.save
      expect(events).to eq(expected_events)
    end
  end

  describe 'when Foo fails to update' do
    before do
      @m.value = :foo
      @m.save
      @m.value = nil
    end

    it 'broadcasts :update_foo_failed' do
      expect {
        @m.save rescue Sequel::ValidationFailed
      }.to broadcast(:update_foo_failed, @m)
    end

    it 'broadcasts all model hook events in the expected order' do
      expected_events = [ :before_validation,
                          :after_validation,
                          :update_foo_failed ]

      events = []
      expected_events.each { |ev| @m.on(ev) { |m| events << ev } }

      @m.save rescue Sequel::ValidationFailed
      expect(events).to eq(expected_events)
    end
  end

  describe 'when Foo is destroyed successfully' do
    before do
      @m.value = :foo
      @m.save
    end

    it 'broadcasts :destroy_foo_successful' do
      expect { @m.destroy }.to broadcast(:destroy_foo_successful, @m)
    end

    it 'broadcasts all model hook events in the expected order' do
      expected_events = [ :before_destroy,
                          :after_destroy,
                          :destroy_foo_successful,
                          :after_destroy_commit ]

      events = []
      expected_events.each { |ev| @m.on(ev) { |m| events << ev } }

      @m.destroy
      expect(events).to eq(expected_events)
    end
  end

  describe 'when Foo fails to destroy' do
    it 'broadcasts :update_foo_failed' do
      expect {
        @m.destroy rescue Sequel::NoExistingObject
      }.to broadcast(:destroy_foo_failed, @m)
    end

    it 'broadcasts all model hook events in the expected order' do
      expected_events = [ :before_destroy,
                          :destroy_foo_failed,
                          :after_destroy_rollback ]

      events = []
      expected_events.each { |ev| @m.on(ev) { |m| events << ev } }

      @m.destroy rescue Sequel::NoExistingObject
      expect(events).to eq(expected_events)
    end
  end
end
