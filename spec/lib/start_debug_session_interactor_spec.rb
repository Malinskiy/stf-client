require File.dirname(__FILE__) + '/../spec_helper'
require 'stf/client'
require 'stf/interactor/start_debug_session_interactor'

describe StartDebugSessionInteractor do
  before :each do
    @stf = Stf::Client.new('http://openstf.io', FakeSTF.fake_token)
  end

  it 'should execute adb connect ' do
    session = StartDebugSessionInteractor.new(@stf)
    expect(session).to receive(:_execute_adb_with)
    session.execute(1, false, 'serial:UDKDU15A20001021', true)
  end

  it 'should not execute adb connect ' do
    session = StartDebugSessionInteractor.new(@stf)
    expect(session).to_not receive(:_execute_adb_with)
    session.execute(1, false, 'serial:UDKDU15A20001021', false)
  end
end
