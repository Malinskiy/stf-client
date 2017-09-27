require File.dirname(__FILE__) + '/../spec_helper'
require 'stf/interactor/get_keys_interactor'

describe Stf::Client do

  before :each do
    @stf = Stf::Client.new('http://openstf.io', FakeSTF.fake_token)
    @interacror = GetKeysInteractor.new(@stf)
  end

  it 'should correctly return list of device parameters' do
    keys = @interacror.execute

    expect(keys).to be_instance_of Array
    expect(keys.length).to eq 65
    expect(keys.first).to eq 'abi'
  end

end