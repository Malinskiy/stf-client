require 'di'
require 'ADB'

require 'stf/client'
require 'stf/log/log'
require 'stf/interactor/stop_debug_session_interactor'
require 'stf/model/device_list'

module Stf
  class StopAllDebugSessionsInteractor
    include Log
    include ADB

    # byFilter:
    # exceptFilter:
    def execute(options = {})
      DI[:demonizer].kill unless options[:nokill]

      stf_devices = DeviceList.new(DI[:stf].get_user_devices)

      stf_devices = stf_devices.byFilter options[:byFilter] if options[:byFilter]
      stf_devices = stf_devices.exceptFilter options[:exceptFilter] if options[:exceptFilter]

      connected_devices = devices()
      remote_devices = stf_devices.asConnectUrlList

      pending_disconnect = connected_devices & remote_devices

      pending_disconnect.each {|d| DI[:stop_debug_session_interactor].execute d}
    end
  end
end
