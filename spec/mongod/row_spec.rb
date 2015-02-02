require 'spec_helper'
require File.expand_path('lib/mongod/row', project_root)
require 'mongo'
include Mongo

RSpec.describe 'Mongod::Row' do

  let(:hash) { {foo: 'foo', bar: 'bar'} }
  let(:row) { Mongod::Row.new(hash) }

  %w{ foo bar }.each do |f|
    context "has .#{f} method?" do
      it ".#{f}" do
        expect(row.respond_to?("#{f}")).to eq(true)
      end
    end
    context "Does .#{f} method set value?" do
      it ".#{f}" do
        expect(row.send("#{f}")).to eq(hash[f.to_sym])
      end
    end
  end

end
