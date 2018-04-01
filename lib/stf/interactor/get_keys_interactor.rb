require 'ADB'
require 'di'

require 'stf/client'
require 'stf/log/log'
require 'stf/model/device'

module Stf
  class GetKeysInteractor
    include Log
    include ADB

    def execute
      devices = DI[:stf].get_devices

      if devices.nil? || (devices.is_a?(Array) && devices.empty?)
        logger.info 'No devices connected to STF'
        return []
      end

      devices
          .map {|d| Device.new(d)}
          .flat_map {|d| d.getKeys}
          .uniq
          .sort
    end
  end
end