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

        shell('echo adbtest', {serial: "#{result.remoteConnectUrl}"}, 30)
        raise ADBError, "Could not execute shell test" unless stdout_contains "adbtest"

        return true

      rescue SignalException => e
        raise e
      rescue => e
        begin
          # we will try clean anyway
          DI[:stf].remove_device serial
          if test ?d, '/custom-metrics'
            File.open('/custom-metrics/openstf_connect_fail', 'a') do
                |f| f.write("openstf_connect_fail,reason=\"#{e.message}\" serial=\"#{serial}\" #{Time.now.to_i}\n")
            end
          end
        rescue
        end

        logger.error "Failed to connect to #{serial}: " + e.message
        return false
      end
    end
  end
end