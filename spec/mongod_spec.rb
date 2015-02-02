require 'spec_helper'

describe Mongod do
  it 'has a version number' do
    expect(Mongod::VERSION).not_to be nil
  end
end
