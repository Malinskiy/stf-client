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
end