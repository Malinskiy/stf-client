require 'spec_helper'
require 'dry/container/stub'
require 'stf/model/device_list'

describe Stf::DeviceList do

  it 'can create empty device list' do
    empty_list = Stf::DeviceList.new({})
    expect(empty_list.empty?).to be true
  end

  it 'should properly return the size' do
    device_list = Stf::DeviceList.new(DI[:stf].get_devices())
    expect(device_list.size).to eq 5
  end

  it 'should respond to asArray' do
    device_list = Stf::DeviceList.new(DI[:stf].get_devices())
    expect(device_list.asArray.size).to eq 5
  end

  it 'should respond to select' do
    device_list = Stf::DeviceList.new(DI[:stf].get_devices())
    expect(device_list.select {|d| d.present == true}.size).to eq 4
  end

  it 'should respond to reject' do
    device_list = Stf::DeviceList.new(DI[:stf].get_devices())
    expect(device_list.reject {|d| d.present == true}.size).to eq 1
  end

  it 'shold get one device by serial' do
    device_list = Stf::DeviceList.new(DI[:stf].get_devices())
    expect(device_list.byFilter('serial:022GPLDU39036997').size).to eq 1
  end

  it 'should return 3 devices connected by WiFi' do
    device_list = Stf::DeviceList.new(DI[:stf].get_devices())
    expect(device_list.healthy('wifi').size).to eq 3
  end

  it 'should return 1 device connected by VPN' do
    device_list = Stf::DeviceList.new(DI[:stf].get_devices())
    expect(device_list.healthy('vpn').size).to eq 1
  end

  it 'should return 4 devices connected to network' do
    device_list = Stf::DeviceList.new(DI[:stf].get_devices())
    expect(device_list.healthy('net').size).to eq 4
  end

  it 'should return 4 devices healthy to connect' do
    device_list = Stf::DeviceList.new(DI[:stf].get_devices())
    expect(device_list.healthyForConnect('battery,temperature,network').size).to eq 2
  end
end