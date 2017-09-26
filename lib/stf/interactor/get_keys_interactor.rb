require 'ADB'

require 'stf/client'
require 'stf/log/log'
require 'stf/errors'
require 'stf/model/session'
require 'pry'
require 'stf/model/device'

class GetKeysInteractor

  include Log
  include ADB

  def initialize(stf)
    @stf = stf
  end

  def execute
    devices = @stf.get_devices

    if devices.nil? || (devices.is_a?(Array) && devices.empty?)
      logger.info 'No devices connected to STF'
      return []
    end

    return devices
             .map {|d| Device.new(d)}
             .flat_map {|d| d.getKeys }
             .uniq
             .sort
  end

end