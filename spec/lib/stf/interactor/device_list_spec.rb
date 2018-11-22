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
    expect(device_list.size).to eq 11
  end

  it 'should respond to asArray' do
    device_list = Stf::DeviceList.new(DI[:stf].get_devices())
    expect(device_list.asArray.size).to eq 11
  end

  it 'should respond to select' do
    device_list = Stf::DeviceList.new(DI[:stf].get_devices())
    expect(device_list.select {|d| d.present == true}.size).to eq 9
  end

  it 'should respond to reject' do
    device_list = Stf::DeviceList.new(DI[:stf].get_devices())
    expect(device_list.reject {|d| d.present == true}.size).to eq 2
  end

  it 'should get one device by serial' do
    device_list = Stf::DeviceList.new(DI[:stf].get_devices())
    expect(device_list.by_filter('serial:022GPLDU39036997').size).to eq 1
  end

  it 'should return 9 devices connected by WiFi' do
    device_list = Stf::DeviceList.new(DI[:stf].get_devices())
    expect(device_list.select_healthy('wifi').size).to eq 9
  end

  it 'should return 1 device connected by VPN' do
    device_list = Stf::DeviceList.new(DI[:stf].get_devices())
    expect(device_list.select_healthy('vpn').size).to eq 1
  end

  it 'should return 10 devices connected to network' do
    device_list = Stf::DeviceList.new(DI[:stf].get_devices())
    expect(device_list.select_healthy('net').size).to eq 10
  end

  it 'should return 8 devices healthy to connect' do
    device_list = Stf::DeviceList.new(DI[:stf].get_devices())
    expect(device_list.select_healthy_for_connect('battery,temperature,network').size).to eq 8
  end

  it 'should return 1 devices with ready to connect status' do
    device_list = Stf::DeviceList.new(DI[:stf].get_devices())
    expect(device_list.select_ready_to_connect.size).to eq 1
  end

end