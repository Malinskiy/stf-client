require 'di'
require 'ADB'

require 'stf/client'
require 'stf/log/log'
require 'stf/errors'
require 'stf/model/session'
require 'stf/model/device'

module Stf
  class GetValuesInteractor

    include Log
    include ADB

    def execute(key)
      devices = DI[:stf].get_devices

      if devices.nil? || (devices.is_a?(Array) && devices.empty?)
        logger.info r 'No devices connected to STF'
        return []
      end

      devices
          .map {|d| Device.new(d)}
          .map {|d| d.getValue(key)}
          .uniq
    end

  end
end