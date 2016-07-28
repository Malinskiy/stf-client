class RemoveAllUserDevicesInteractor

  def initialize(stf)
    @stf = stf
  end

  def execute
    devices = @stf.get_user_devices
    devices.each { |d| @stf.remove_device d.serial }
  end
end