require 'di'
require 'ADB'

require 'stf/client'
require 'stf/log/log'
require 'stf/errors'

module Stf
  class StopDebugSessionInteractor
    include Log
    include ADB

    def execute(remote_connect_url)
      remote_devices = DI[:stf].get_user_devices
      device = remote_devices.find {|d| d.remoteConnect == true && d.remoteConnectUrl.eql?(remote_connect_url)}

      # try to disconnect anyway
      execute_adb_with 30, "disconnect #{remote_connect_url}"

      if device.nil?
        logger.error "Device #{remote_connect_url} is not available"
        return false
      end

      success = false

      1..10.times do
        begin
          success = DI[:stf].stop_debug(device.serial)
          break if success
        rescue
        end

        logger.error 'Can\'t stop debug session. Retrying'
      end

      1..10.times do
        begin
          success = DI[:stf].remove_device(device.serial)
          break if success
        rescue
        end
        logger.error 'Can\'t remove device from user devices. Retrying'
      end

      if success
        logger.info "Successfully removed #{remote_connect_url}"
      else
        logger.error "Error removing #{remote_connect_url}"
      end

      success
    end
  end
end
