require File.dirname(__FILE__) + '/../spec_helper'
require 'stf/interactor/get_values_interactor'

describe Stf::Client do

  before :each do
    @stf = Stf::Client.new('http://openstf.io', FakeSTF.fake_token)
    @interacror = GetValuesInteractor.new(@stf)
  end

  it 'should correctly return values by simple key' do
    keys = @interacror.execute('abi')

    expect(keys).to eq ['arm64-v8a', 'armeabi-v7a']
  end

  it 'should correctly return values by composite key' do
    keys = @interacror.execute('provider.name')

    expect(keys).to eq ['19c4bdfb8812', '330dad7e0323']
  end
end