require 'stf/model/device'

module Stf
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
      filter ? select {|d| d.checkFilter(filter)} : []
    end

    def exceptFilter(filter)
      filter ? reject {|d| d.checkFilter(filter)} : this
    end

    def healthy(pattern)
      pattern ? select { |d| d.isHealthy(pattern) } : this
    end

    # more pessimistic than healthy()
    def healthyForConnect(pattern)
      pattern ? select { |d| d.isHealthyForConnect(pattern) } : this
    end

    def notHealthy(pattern)
      pattern ? reject { |d| d.isHealthy(pattern) } : []
    end

    def filterReadyToConnect
      # https://github.com/openstf/stf/blob/93d9d7fe859bb7ca71669f375d841d94fa47d751/lib/wire/wire.proto#L170
      # enum DeviceStatus {
      #   OFFLINE = 1;
      #   UNAUTHORIZED = 2;
      #   ONLINE = 3;
      #   CONNECTING = 4;
      #   AUTHORIZING = 5;
      # }
      #
      # https://github.com/openstf/stf/blob/93d9d7fe859bb7ca71669f375d841d94fa47d751/res/app/components/stf/device/enhance-device/enhance-device-service.js
      select {|d|
        d.present == true &&
            d.status == 3 &&
            d.ready == true &&
            d.using == false &&
            d.owner.nil?
      }
    end

    def asConnectUrlList
      @devices.map {|d| d.remoteConnectUrl}.reject { |c| c.nil? || c.empty? }
    end

    def select
      DeviceList.new(@devices.select {|d| yield(d)})
    end

    def reject
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
end
