require File.dirname(__FILE__) + '/../spec_helper'
require 'stf/interactor/get_values_interactor'

describe Stf::Client do

  before :each do
    stf = Stf::Client.new('http://openstf.io', FakeSTF.fake_token)
    @list = stf.get_devices
  end

  it 'should correctly show device parameters' do
    devices = @list.map {|d| Device.new(d)}

    key = 'provider.name'
    value = '19c4bdfb8812'
    expected = @list.select {|d| d.provider.name == value }.length
    expect(expected).to be > 0

    actual = devices.select do |d|
      d.getValue(key) == value
    end

    expect(actual.length).to eq expected
  end
end