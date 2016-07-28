class DeviceNotAvailableError < StandardError
  def message
    'Device not available'
  end
end