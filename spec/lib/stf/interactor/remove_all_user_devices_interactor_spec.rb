require 'spec_helper'
require 'stf/interactor/remove_all_user_devices_interactor'
require 'dry/container/stub'

describe Stf::RemoveAllUserDevicesInteractor do

  before do
    demonizer = instance_double('Stf::Demonizer')
    allow(demonizer).to receive(:kill)
    allow(demonizer).to receive(:run)
    DI.container.stub(:demonizer, demonizer)
  end

  it 'should remove all devices' do
    interactor = Stf::RemoveAllUserDevicesInteractor.new
    expect(interactor.execute.size).to be 1
  end
end