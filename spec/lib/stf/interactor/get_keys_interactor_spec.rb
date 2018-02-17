require 'spec_helper'
require 'stf/interactor/get_keys_interactor'

describe Stf::GetKeysInteractor do

  before :each do
    @interactor = Stf::GetKeysInteractor.new
  end

  it 'should correctly return list of device parameters' do
    keys = @interactor.execute

    expect(keys).to be_instance_of Array
    expect(keys.length).to eq 65
    expect(keys.first).to eq 'abi'
  end

end