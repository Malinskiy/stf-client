require 'spec_helper'
require 'stf/interactor/start_debug_session_interactor'
require 'dry/container/stub'

describe Stf::StartDebugSessionInteractor do

  before do
    demonizer = instance_double("Stf::Demonizer")
    allow(demonizer).to receive(:kill)
    allow(demonizer).to receive(:run)
    DI.container.stub(:demonizer, demonizer)

    allow_any_instance_of(ADB).to receive(:execute_adb_with).and_return(true)
    allow_any_instance_of(ADB).to receive(:devices).and_return(['openstf.io:7405'])
  end

  after do
    allow_any_instance_of(ADB).to receive(:execute_adb_with).and_call_original
    allow_any_instance_of(ADB).to receive(:devices).and_call_original
  end

  it 'should connect without demonizer' do
    interactor = Stf::StartDebugSessionInteractor.new

    allow_any_instance_of(ADB).to receive(:execute_adb_with).and_return(true)
    allow_any_instance_of(ADB).to receive(:devices).and_return(['openstf.io:7405'])

    expect(interactor.execute).to be true
  end
end