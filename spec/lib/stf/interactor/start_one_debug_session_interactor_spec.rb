require 'spec_helper'
require 'stf/interactor/start_one_debug_session_interactor'
require 'dry/container/stub'

describe Stf::StartOneDebugSessionInteractor do

  before do
    allow_any_instance_of(ADB).to receive(:execute_adb_with).with(30, '-s openstf.io:7401 wait-for-device shell echo adbtest')
    allow_any_instance_of(ADB).to receive(:execute_adb_with).with(30, 'connect openstf.io:7401').and_return(true)
    allow_any_instance_of(ADB).to receive(:last_stdout).and_return("\nadbtestopenstf.io:7401\tdevice")
  end

  after do
    allow_any_instance_of(ADB).to receive(:execute_adb_with).with(30, '-s openstf.io:7401 wait-for-device shell exit').and_call_original
    allow_any_instance_of(ADB).to receive(:execute_adb_with).with(30, 'connect openstf.io:7401').and_call_original
    allow_any_instance_of(ADB).to receive(:last_stdout).and_call_original
  end

  it 'should connect one devices and return true' do
    interactor = Stf::StartOneDebugSessionInteractor.new
    expect(interactor.execute(OpenStruct.new({serial: 'fakeserial'}))).to be true
  end
end