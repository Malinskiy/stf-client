require 'stf/model/device'

# can not inherite from Array because http://words.steveklabnik.com/beware-subclassing-ruby-core-classes
class DeviceList
  def initialize(devices)
    if devices.nil?
      @devices = Array.new
    else
      @devices = devices.map {|d| (d.kind_of? Device) ? d : Device.new(d)}
    end
  end

  def byFilter(filter)
    filter ? select {|d| d.checkFilter(filter)} : Array.new
  end

  def exceptFilter(filter)
    filter ? reject {|d| d.checkFilter(filter)} : this
  end

  def filterReadyToConnect
    select {|d| d.ready == true && d.present == true && d.using == false}
  end

  def asConnectUrlList
    @devices.map {|d| d.remoteConnectUrl}
  end

  def select
    DeviceList.new(@devices.select {|d| yield(d)})
  end

  def reject
    # DeviceList.new(@devices.reject {|d| yield(d)})
    DeviceList.new(@devices.select {|d| !yield(d)})
  end

  def empty?
    @devices.empty?
  end

  def size
    @devices.size
  end

  def asArray
    @devices
  end
end