require 'spec_helper'

describe Mongod do
  it 'has a version number' do
    expect(Mongod::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
