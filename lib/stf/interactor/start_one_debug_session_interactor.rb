require 'di'
require 'ADB'

require 'stf/client'
require 'stf/log/log'
require 'stf/errors'
require 'stf/model/session'

module Stf
  class StartOneDebugSessionInteractor

    include Log
    include ADB

    def execute(device)
      return false if device.nil?
      serial = device.serial

      begin
        success = DI[:stf].add_device serial
        if success
          logger.info "Device added #{serial}"
        else
          logger.error "Can't add device #{serial}"
          raise
        end

        result = DI[:stf].start_debug serial
        if result.success
          logger.info "Debug started #{serial}"
        else
          logger.error "Can't start debugging session for device #{serial}"
          raise
        end

        execute_adb_with 30, "connect #{result.remoteConnectUrl}"

        # Check for adb device status
        execute_adb_with(30, 'devices')
        device_list = last_stdout.split("\n")
        device_list.shift
        devices = Hash[device_list.collect {|device| [device.split("\t").first, device.split("\t").last]}]

        if devices["#{result.remoteConnectUrl}"] != "device"
          raise "adb connect #{result.remoteConnectUrl} succeeded but device is not in the adb devices list"
        end

        shell('exit', {serial: "#{result.remoteConnectUrl}"}, 30)

        return true

      rescue SignalException => e
        raise e
      rescue => e
        begin
          # we will try clean anyway
          DI[:stf].remove_device serial
        rescue
        end

        logger.error "Failed to connect to #{serial}: " + e.message
        return false
      end
    end
  end
end