require 'ADB'

require 'stf/client'
require 'stf/log/log'
require 'stf/errors'
require 'stf/model/session'
require 'pry'
require 'stf/model/device'

class ShowValuesInteractor

  include Log
  include ADB

  def initialize(stf)
    @stf = stf
  end

  def execute(key)
    devices = @stf.get_devices

    if devices.nil? || (devices.is_a?(Array) && devices.empty?)
      logger.info r 'No devices connected to STF'
      return
    end

    puts devices
             .map {|d| Device.new(d)}
             .map {|d| d.getValue(key)}
             .uniq
  end

end