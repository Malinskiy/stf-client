require 'ADB'

require 'stf/client'
require 'stf/log/log'
require 'stf/errors'

class StopDebugSessionInteractor

  include Log
  include ADB

  def initialize(stf)
    @stf = stf
  end

  def execute(remoteConnectUrl)
    remote_devices = @stf.get_user_devices
    device         = remote_devices.find { |d| d.remoteConnect == true && d.remoteConnectUrl.eql?(remoteConnectUrl) }

    raise DeviceNotAvailableError if device.nil?

    execute_adb_with 30, "disconnect #{device.remoteConnectUrl}"

    success = false

    1..10.times do
      success = @stf.stop_debug(device.serial)
      if success == true
        break
      elsif logger.error 'Can\'t stop debug session. Retrying'
      end
    end

    1..10.times do
      success = @stf.remove_device(device.serial)
      if success == true
        break
      elsif logger.error 'Can\'t remove device from user devices. Retrying'
      end
    end

    if success == true
      logger.info "Successfully removed #{remoteConnectUrl}"
    elsif logger.error "Error removing #{remoteConnectUrl}"
    end

    return success
  end
end