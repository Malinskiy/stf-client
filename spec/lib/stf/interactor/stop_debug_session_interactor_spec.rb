require 'spec_helper'
require 'stf/interactor/stop_debug_session_interactor'
require 'dry/container/stub'

describe Stf::StopDebugSessionInteractor do

  before do
    allow_any_instance_of(ADB).to receive(:execute_adb_with).with(30, "disconnect openstf.io:7405").and_return(true)
    allow_any_instance_of(ADB).to receive(:devices).and_return(['openstf.io:7405'])
  end

  after do
    allow_any_instance_of(ADB).to receive(:execute_adb_with).and_call_original
    allow_any_instance_of(ADB).to receive(:devices).and_call_original
  end

  it 'should disconnect' do
    interactor = Stf::StopDebugSessionInteractor.new
    expect(interactor.execute('openstf.io:7405')).to be true
  end
end