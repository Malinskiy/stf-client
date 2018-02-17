require 'ADB'

require 'stf/client'
require 'stf/log/log'
require 'stf/errors'
require 'stf/model/session'
require 'stf/model/device_list'

class StartDebugSessionInteractor

  include Log
  include ADB

  def execute(opts = {})
    all_flag = opts[:all]
    forever_flag = opts[:forever]
    nodaemon_flag = opts[:nodaemon]
    filter = opts[:filter]
    max_n = opts[:n].to_i > 0 ? opts[:n].to_i : 1
    start_timeout = opts[:starttime].to_i > 0 ? opts[:starttime].to_i : 120
    session = opts[:worktime].to_i > 0 ? opts[:session].to_i : 10800
    min_n = opts[:min].to_s.empty? ? (max_n + 1) / 2 : opts[:min].to_i

    DI[:demonizer].kill unless opts[:nokill]

    if filter
      DI[:stop_all_debug_sessions_interactor].execute(exceptFilter: filter)
    end

    wanted = nodaemon_flag ? max_n : min_n

    begin
      connect_loop(all_flag, wanted, filter, false, 5, start_timeout)

    rescue SignalException => e
      DI[:stop_all_debug_sessions_interactor].execute
      return false

    rescue
    end

    connected_count = count_connected_devices(filter)
    if all_flag ? connected_count.zero? : connected_count < wanted
      DI[:stop_all_debug_sessions_interactor].execute
      return false
    end

    logger.info "Lower quantity achieved, already connected #{connected_count}"

    return if nodaemon_flag

    # will be daemon here
    DI[:demonizer].run do
      connect_loop(all_flag,
                   max_n,
                   filter,
                   true,
                   30,
                   session,
                   forever_flag)

      DI[:stop_all_debug_sessions_interactor].execute(byFilter: filter, nokill: true)
    end
  end

  def connect_loop(all_flag, wanted, filter, infinite_flag, delay, timeout, forever_flag=false)
    finish_time = Time.now + timeout

    while forever_flag || Time.now < finish_time do
      cleanup_disconnected_devices(filter)

      stf_devices = DeviceList.new(DI[:stf].get_devices)
      stf_devices = stf_devices.byFilter(filter) if filter

      if all_flag
        batch = stf_devices.filterReadyToConnect.size
      else
        connected = devices & stf_devices.asConnectUrlList
        batch = wanted - connected.size
      end

      if batch > 0
        connect(filter, all_flag, batch)
      elsif !infinite_flag
        break
      end

      sleep delay
    end

  end

  def count_connected_devices(filter)
    stf_devices = DeviceList.new(DI[:stf].get_user_devices)
    stf_devices = stf_devices.byFilter(filter) if filter
    connected = devices & stf_devices.asConnectUrlList
    connected.size
  end

  def cleanup_disconnected_devices(filter)
    stf_devices = DeviceList.new(DI[:stf].get_user_devices)
    stf_devices = stf_devices.byFilter(filter) if filter
    connected = stf_devices.asConnectUrlList - devices

    connected.reject { |url| url.to_s.empty? }.each do |url|
      logger.info 'Cleanup the device ' + url.to_s
      DI[:stop_debug_session_interactor].execute(url)
    end
  end

  def connect(filter, all_flag, wanted)
    devices = DeviceList.new(DI[:stf].get_devices)
    devices = devices.filterReadyToConnect
    devices = devices.byFilter(filter) if filter

    if devices.empty?
      logger.error 'There is no available devices with criteria ' + filter
      return 0
    end

    n = 0
    devices.asArray.shuffle.each do |d|
      n += 1 if DI[:start_one_debug_session_interactor].execute(d)
      break if !all_flag && n >= wanted
    end

    n
  end

end