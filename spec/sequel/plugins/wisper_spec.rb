require 'spec_helper'
require 'sequel'

describe Sequel::Plugins::Wisper do
  before(:all) do
    @db = Sequel.mock(host: 'mysql', numrows: 1)

    class ::WisperModel < Sequel::Model(@db[:wisper])
      plugin :wisper
      plugin :schema

      set_schema do
        primary_key :id
        String :value
      end
    end
    WisperModel.create_table!
  end

  before do
    @m = WisperModel.new
  end

  describe 'on validation' do
    it 'broadcasts on #before_validation and #after_validation hooks' do
      events = []
      @m.on(:before_validation) { events << :before_validation }
      @m.on(:after_validation) { events << :after_validation }

      @m.valid?
      expect(events).to eq([:before_validation, :after_validation])
    end
  end

  describe 'on #save with a new instance' do
    it 'broadcasts on #before_save and #after_save' do
      events = []
      @m.on(:before_save) { events << :before_save }
      @m.on(:after_save) { events << :after_save }

      @m.save rescue nil
      expect(events).to eq([:before_save, :after_save])
    end
  end
end
