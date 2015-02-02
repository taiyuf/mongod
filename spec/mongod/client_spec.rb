require 'spec_helper'
require File.expand_path('lib/mongod/client', project_root)
require 'mongo'
require 'mongod/row'
include Mongo

RSpec.describe 'Mongod::Client' do

  let(:database) { 'test' }
  let(:collection) { 'test' }
  let(:host) { '127.0.0.1' }
  let(:port) { 27017 }
  let(:default_opts) { { database:   database,
                         collection: collection,
                         host:       host,
                         port:       port } }

  before do @c = Mongod::Client.new(default_opts) end

  context '.initialize' do

    context 'raise error when no arguments.' do
      %w{ database collection }.each do |f|
        it ".#{f}" do
          opts = { database:   database,
                   collection: collection,
                   host:       host,
                   port:       port }
          opts.delete(f.to_sym)
          expect{ Mongod::Client.new(opts) }.to raise_error(RuntimeError, "*** Mongod::Client: '#{f}' is required!")
        end
      end
    end

    context 'in regular' do
      # before do @c = Mongod::Client.new(default_opts) end

      %w{ database collection host port }.each do |f|
        it ".#{f}" do
          expect(@c.send(f.to_sym)).to eq(default_opts[f.to_sym])
        end
      end
      it '.per_page' do
        expect(@c.per_page).to eq(20)
      end
    end

  end

  context 'validation' do

    it 'host info is not "String" object.' do
      expect(@c.send('check_host_info', 0)).to             eq(false)
      expect(@c.send('check_host_info', 'hoge')).to        eq(false)
      expect(@c.send('check_host_info', '192.168.0.1')).to eq(true)
      expect(@c.send('check_host_info', 'localhost')).to   eq(true)
    end

    it 'hosts info\'s format is not valid 1' do
      @c.host = 'hoge'
      @c.connect
      expect(@c.errors.has_key?(:host)).to eq(true)
    end
    it 'hosts info\'s format is not valid 2' do
      @c.port = 'hoge'
      @c.connect
      expect(@c.errors.has_key?(:port)).to eq(true)
    end

    it 'shoud be valid 1' do
      expect(@c.send('check_host_info', '127.0.0.1')).to eq(true)
    end
    it 'shoud be valid 2' do
      expect(@c.send('check_host_info', 'localhost')).to eq(true)
    end
  end

  context 'connect method' do
    it 'shoud be Mongo::Connection class' do
      expect(@c.connect).to be_kind_of(Mongo::MongoClient)
    end
  end

  context 'get_db method' do
    it 'get_db' do
      expect(@c.get_db).to be_kind_of(Mongo::DB)
    end
  end

  context 'get_collection method' do

    before do @c.connect end

    it 'should be RuntimeError if self.collection = nil' do
      @c.collection = nil
      expect{@c.get_collection}.to raise_error(RuntimeError, '*** Mongod::get_collection: Please set the value of collection')
    end

    it 'should be ' do
      @c.collection = 'test'
      expect(@c.get_collection).to be_kind_of(Mongo::Collection)
    end

  end

  context 'CRUD' do

    before do
      @name  = 'hoge'
      dummy  = { '_id'  => BSON::ObjectId('4f7b1ea6e4d30b35c9000001'),
                 'name' => @name }
      @c = Mongod::Client.new(default_opts)
      @c.drop_database(database)
      @c.get_db(database)
      @c.collection = collection

      # allow(@c).to receive(:create)
      #              .with({ name: @name })
      #              .and_return(dummy['_id'])
      # allow(@c).to receive(:where)
      #              .with({ name: @name })
      #              .and_return(@c.instance_variable_set(:@_result,
      #                                                   [ Mongod::Row.new(dummy) ]))
      # allow(@c).to receive(:delete)
      #               .and_return(@c.instance_variable_set(:@_result, []))
    end

    it '.create' do
      expect(@c.create({ name: @name })).to be_kind_of(BSON::ObjectId)
    end

    it '.where' do
      @c.create({ name: @name })
      array = @c.where({ name: @name }).to_a
      expect(array[0].name).to eq(@name)
    end

    it '.delete' do
      @c.create({ name: @name })
      array = @c.where({ name: @name }).delete.to_a
      expect(array).to eq([])
    end

    after do
      @c.drop_database('test')
    end
  end

end
