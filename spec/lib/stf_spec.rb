require 'spec_helper'

describe Stf::Client do

  before :each do
    @stf = DI[:stf]
  end

  it 'should correctly get devices' do
    devices = @stf.get_devices

    expect(devices).to be_instance_of Array
  end

  it 'should correctly get device by serial' do
    device = @stf.get_device 'UDKDU15A20001021'

    expect(device.serial).to eq 'UDKDU15A20001021'
  end

  it 'should correctly get user' do
    user = @stf.get_user

    expect(user.email).to eq 'stf@openstf.io'
  end

  it 'should correctly get user device' do
    devices = @stf.get_user_devices

    expect(devices).to be_instance_of Array
  end

  it 'should correctly add device' do
    result = @stf.add_device 'UDKDU15A20001021'

    expect(result).to be true
  end

  it 'should correctly start debug session' do
    url = @stf.start_debug('UDKDU15A20001021').remoteConnectUrl

    expect(url).to eq 'openstf.io:7401'
  end

  it 'should correctly stop debug session' do
    expect(@stf.stop_debug('UDKDU15A20001021')).to be true
  end

  it 'should correcly remove device' do
    expect(@stf.remove_device('UDKDU15A20001021')).to be true
  end

  it 'should correctly show device parameters' do
    list = @stf.get_devices
    devices = list.map {|d| Stf::Device.new(d)}

    key = 'provider.name'
    value = '19c4bdfb8812'
    expected = list.select {|d| d.provider.name == value }.length
    expect(expected).to be > 0

    actual = devices.select do |d|
      d.getValue(key) == value
    end

    expect(actual.length).to eq expected
  end

  it 'should correctly add adb public key' do
    result = @stf.add_adb_public_key 'UDKDU15A20001021 foo@foo.foo'

    expect(result).to be true
  end

end