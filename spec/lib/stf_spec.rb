require File.dirname(__FILE__) + '/../spec_helper'

describe Stf::Client do

  before :each do
    @stf = Stf::Client.new('http://openstf.io', FakeSTF.fake_token)
  end

  it 'should correctly get devices' do
    devices = @stf.get_devices

    expect(devices).instance_of? Array
  end

  it 'should correctly get device by serial' do
    device = @stf.get_device 'UDKDU15A20001021'

    expect(device.serial).eql? 'UDKDU15A20001021'
  end

  it 'should correctly get user' do
    user = @stf.get_user

    expect(user.email).eql? 'stf@openstf.io'
  end

  it 'should correctly get user device' do
    devices = @stf.get_user_devices

    expect(devices).instance_of? Array
  end

  it 'should correctly add device' do
    expect(@stf.add_device 'UDKDU15A20001021').to be true
  end

  it 'should correctly start debug session' do
    expect(@stf.start_debug('UDKDU15A20001021').remoteConnectUrl).eql? 'openstf.io:7401'
  end

  it 'should correctly stop debug session' do
    expect(@stf.stop_debug('UDKDU15A20001021')).to be true
  end

  it 'should correcly remove device' do
    expect(@stf.remove_device('UDKDU15A20001021')).to be true
  end

end