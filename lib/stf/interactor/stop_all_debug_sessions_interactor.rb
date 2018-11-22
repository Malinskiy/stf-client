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
    def execute(options = {})
      DI[:demonizer].kill unless options[:nokill]

      stf_devices = DeviceList.new(DI[:stf].get_user_devices)

      stf_devices = stf_devices.by_filter options[:byFilter] if options[:byFilter]

      pending_disconnect = stf_devices.as_connect_url_list

      pending_disconnect.each {|d| DI[:stop_debug_session_interactor].execute d}
    end
  end
end
