require 'ADB'

require 'stf/client'
require 'stf/log/log'
require 'stf/model/device_list'

module Stf
  class StartDebugSessionInteractor

    include Log
    include ADB

    def execute(opts = {})
      all_flag = opts[:all]
      nodaemon_flag = opts[:nodaemon]
      filter = opts[:filter]
      max_n = opts[:n].to_i > 0 ? opts[:n].to_i : 1
      start_timeout = opts[:starttime].to_i > 0 ? opts[:starttime].to_i : 120
      session = opts[:worktime].to_i > 0 ? opts[:session].to_i : 10800
      min_n = opts[:min].to_s.empty? ? (max_n + 1) / 2 : [opts[:min].to_i, max_n].min
      healthcheck = opts[:health]
      force_filter = opts[:forcefilter]

      DI[:demonizer].kill unless opts[:nokill]

      wanted = nodaemon_flag ? max_n : min_n

      begin
        connect_loop(all_flag: all_flag,
                     wanted: wanted,
                     filter: filter,
                     force_filter: force_filter,
                     healthcheck: healthcheck,
                     delay: 5,
                     timeout: start_timeout)

      rescue SignalException => e
        logger.info "Caught signal \"#{e.message}\""
        DI[:stop_all_debug_sessions_interactor].execute
        return false
      rescue Exception => e
        logger.info "Exception \"#{e.message}\" during initial connect loop"
        DI[:stop_all_debug_sessions_interactor].execute
        return false
      end

      connected_count = count_connected_devices(filter)
      logger.info "Lower quantity achieved, already connected #{connected_count}"

      return true if nodaemon_flag

      # will be daemon here
      DI[:demonizer].run do
        connect_loop(all_flag: all_flag,
                     wanted: max_n,
                     filter: filter,
                     force_filter: force_filter,
                     healthcheck: healthcheck,
                     daemon_mode: true,
                     delay: 30,
                     timeout: session)

        DI[:stop_all_debug_sessions_interactor].execute(byFilter: filter, nokill: true)
      end

      return true
    end

    def connect_loop(all_flag: false,
                     wanted: 1,

                     filter: nil,
                     force_filter: false,
                     healthcheck: nil,

                     daemon_mode: false,
                     delay: 5,
                     timeout: 120)
      finish_time = Time.now + timeout
      one_time_mode = !daemon_mode

      while true do
        cleanup_disconnected_devices(filter, force_filter, healthcheck)

        if one_time_mode && Time.now > finish_time
          raise "Connect loop timeout reached"
        end

        all_devices = DeviceList.new(DI[:stf].get_devices)
        stf_devices = all_devices.select_ready_to_connect
        stf_devices = stf_devices.by_filter(filter) if filter
        stf_devices = stf_devices.select_healthy_for_connect(healthcheck) if healthcheck

        if all_flag
          to_connect = stf_devices.size
        else
          connected = devices & all_devices.as_connect_url_list
          to_connect = wanted - connected.size
        end

        return if one_time_mode && to_connect <= 0

        if to_connect > 0
          if stf_devices.empty?
            logger.error 'There is no available devices with criteria ' + filter
          else
            random_device = stf_devices.asArray.sample
            DI[:start_one_debug_session_interactor].execute(random_device)
            next
          end
        end

        sleep delay
      end
    end

    def count_connected_devices(filter)
      stf_devices = DeviceList.new(DI[:stf].get_user_devices)
      stf_devices = stf_devices.by_filter(filter) if filter
      connected = devices & stf_devices.as_connect_url_list
      connected.size
    end

    def cleanup_disconnected_devices(filter, force_filter, healthcheck)
      to_disconnect = []
      stf_devices = DeviceList.new(DI[:stf].get_user_devices)

      if filter && force_filter
        disconnect_because_filter = stf_devices.except_filter(filter).as_connect_url_list
        unless disconnect_because_filter.empty?
          logger.info 'will be disconnected by filter: ' + disconnect_because_filter.join(',')
          to_disconnect += disconnect_because_filter
        end
      end

      if healthcheck
        disconnect_by_health = stf_devices.select_not_healthy(healthcheck).as_connect_url_list
        unless disconnect_by_health.empty?
          logger.info 'will be disconnected by health check: ' + disconnect_by_health.join(',')
          to_disconnect += disconnect_by_health
        end
      end

      dead_persons = stf_devices.as_connect_url_list - devices
      unless dead_persons.empty?
        logger.info 'will be disconnected because not present locally: ' + dead_persons.join(',')
        to_disconnect += dead_persons
      end

      to_disconnect.reject {|url| url.to_s.empty?}.uniq.each do |url|
        logger.info 'Cleanup the device ' + url.to_s
        DI[:stop_debug_session_interactor].execute(url)
      end
    end
  end
end
