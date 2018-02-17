require 'di'

module Stf
  class RemoveAllUserDevicesInteractor
    def execute(opts = {})
      DI[:demonizer].kill unless opts[:nokill]

      devices = DI[:stf].get_user_devices
      devices.each {|d| DI[:stf].remove_device d.serial}
    end
  end
end
