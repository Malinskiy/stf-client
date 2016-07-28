require 'ADB'

require_relative '../../../lib/stf/client'
require_relative '../../../lib/stf/log/log'
require_relative '../../../lib/stf/errors'
require_relative '../../../lib/stf/model/session'

class StartDebugSessionInteractor

  include Log
  include ADB

  def initialize(stf)
    @stf = stf
  end

  def execute
    randomized_device = nil

    1..10.times do
      begin
        devices = @stf.get_devices
        if devices.nil? || (devices.is_a?(Array) && devices.empty?)
          logger.info 'No devices connected to STF. Retrying'
          sleep 5
          next
        end
        usable_devices = devices.select { |device| device.using == false }
        if usable_devices.empty?
          logger.error 'All devices are being used. Retrying'
          sleep 5
          next
        end

        randomized_device = usable_devices.sample
        raise new DeviceNotAvailableError if randomized_device.nil?

        serial  = randomized_device.serial
        success = @stf.add_device serial
        if success
          logger.info "Device #{serial} added"
        elsif logger.error "Can't add device #{serial}. Retrying"
          next
        end

        result = @stf.start_debug serial
        if !result.success
          logger.error "Can't start debugging session for device #{serial}. Retrying"
          @stf.remove_device serial
          next
        end

        execute_adb_with 30, "connect #{result.remoteConnectUrl}"

        return Session.new(serial, result.remoteConnectUrl)
        break

        raise new DeviceNotAvailableError
      rescue DeviceNotAvailableError
        logger.error 'Failed to start debug session. Retrying...'
        next
      end
    end
  end
end