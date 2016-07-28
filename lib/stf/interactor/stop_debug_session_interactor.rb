require 'ADB'

require_relative '../../../lib/stf/client'
require_relative '../../../lib/stf/log/log'
require_relative '../../../lib/stf/errors'

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
      break if success == true
    end

    1..10.times do
      success = @stf.remove_device(device.serial)
      break if success == true
    end

    return success
  end
end