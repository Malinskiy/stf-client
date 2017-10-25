require 'ADB'

require 'stf/client'
require 'stf/log/log'
require 'stf/errors'
require 'stf/model/session'

class StartDebugSessionInteractor

  include Log
  include ADB

  def initialize(stf)
    @stf = stf
  end

  def execute(wanted, all_flag, filter, auto_adb_connect)
    wanted = 1 if wanted.nil?
    wanted = wanted.to_i

    1..10.times do
      wanted -= connect(wanted, all_flag, filter, auto_adb_connect)
      return if all_flag || wanted <= 0
      logger.info 'We are still waiting for ' + wanted.to_s + ' device(s). Retrying'
      sleep 5
    end
  end

  def connect(wanted, all_flag, filter, auto_adb_connect)
    devices = @stf.get_devices
    if devices.nil? || (devices.is_a?(Array) && devices.empty?)
      logger.info 'No devices connected to STF'
      return 0
    end

    usable_devices = devices
                         .map {|d| Device.new(d)}
                         .select do |d|
      d.ready == true && d.present == true && d.using == false
    end

    if usable_devices.empty?
      logger.error 'All devices are being used'
      return 0
    end

    unless filter.nil?
      key, value = filter.split(':', 2)

      usable_devices = usable_devices.select do |d|
        d.getValue(key) == value
      end
    end

    if usable_devices.empty?
      logger.error 'There is no device with criteria ' + filter
      return 0
    end

    n = 0
    usable_devices.shuffle.each do |d|
      n += 1 if connect_device(d, auto_adb_connect)
      break if !all_flag && n >= wanted
    end

    n
  end

  def connect_device(device, auto_adb_connect = true)
    begin
      return false if device.nil?

      serial = device.serial
      success = @stf.add_device serial
      if success
        logger.info "Device #{serial} added"
      elsif logger.error "Can't add device #{serial}"
        return false
      end

      result = @stf.start_debug serial
      unless result.success
        logger.error "Can't start debugging session for device #{serial}"
        @stf.remove_device serial
        return false
      end

      if auto_adb_connect
        _execute_adb_with 30, "connect #{result.remoteConnectUrl}"
      else
        logger.info "remoteConnectUrl: #{result.remoteConnectUrl}"
      end
      return true

    rescue Net::HTTPFatalError
      logger.error 'Failed to start debug session'
      return false
    end
  end

  def _execute_adb_with(timeout, cmd)
    execute_adb_with timeout, cmd
  end

end