require 'ADB'

require 'stf/client'
require 'stf/log/log'
require 'stf/model/device_list'

module Stf
  class StartDebugShareInteractor

    def initialize(decision)
      @decision = decision
    end

    include Log
    include ADB

    def execute(opts = {})
      nodaemon_flag = opts[:nodaemon]
      filter = opts[:filter]
      start_timeout = opts[:starttime].to_i > 0 ? opts[:starttime].to_i : 120
      session_duration = opts[:session].to_i > 0 ? opts[:session].to_i : 10800
      healthcheck = opts[:health]

      connected = []

      DI[:demonizer].kill unless opts[:nokill]

      begin
        start_loop(filter: filter,
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

      logger.info "Lower quantity achieved"

      my_name = get_my_name
      logger.info "I am #{my_name}"

      next_step = -> {
        begin
          connect_loop(filter: filter,
                       healthcheck: healthcheck,
                       delay: 5,
                       session_duration: session_duration,
                       laziness_delay: 2,
                       connected_stack: connected)

          DI[:stop_all_debug_sessions_interactor].execute(byFilter: filter, nokill: true)

        rescue SignalException => e
          logger.info "Caught signal \"#{e.message}\""
          DI[:stop_all_debug_sessions_interactor].execute
          return false

        rescue Exception => e
          logger.error "Exception \"#{e.message}\" during lifecycle loop"
          logger.error "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
          DI[:stop_all_debug_sessions_interactor].execute
          return false
        end
      }

      if nodaemon_flag
        next_step.call
      else
        # will be daemon here
        DI[:demonizer].run do
          next_step.call
        end
      end

      true
    end

    def start_loop(wanted: 2,
                   filter: nil,
                   healthcheck: nil,
                   delay: 2,
                   timeout: 120)

      finish_time = Time.now + timeout

      while true do
        cleanup_disconnected_devices(filter: filter, healthcheck: healthcheck)

        if Time.now > finish_time
          raise "Connect loop timeout reached"
        end

        all_devices = DeviceList.new(DI[:stf].get_devices)
        stf_devices = all_devices.select_ready_to_connect
        stf_devices = stf_devices.by_filter(filter) if filter
        stf_devices = stf_devices.select_healthy_for_connect(healthcheck) if healthcheck

        connected = devices & all_devices.as_connect_url_list
        to_connect = wanted - connected.size

        return if to_connect <= 0

        if stf_devices.empty?
          logger.error 'There is no available devices with criteria ' + filter
        else
          random_device = stf_devices.asArray.sample
          DI[:start_one_debug_session_interactor].execute(random_device)
          next # no delay for next device
        end

        sleep delay
      end
    end

    def connect_loop(filter:, healthcheck:, delay:, session_duration:, laziness_delay:, connected_stack:)

      finish_time = Time.now + session_duration

      while true do
        cleanup_disconnected_devices(filter: filter, healthcheck: healthcheck)

        raise "Session timeout reached" if Time.now > finish_time

        all_devices = DeviceList.new(DI[:stf].get_devices)
        stf_devices = all_devices.by_filter(filter) if filter
        stf_devices = stf_devices.select_healthy_for_connect(healthcheck) if healthcheck

        connected = devices & all_devices.as_connect_url_list
        free = stf_devices.select_ready_to_connect
        brothers = stf_devices
                       .select_using_by_someone_else
                       .asArray
                       .group_by {|d| d.owner.name}
                       .map {|k, v| [k, v.length]}
                       .to_h

        logger.debug "brothers #{brothers}"

        big_brother = brothers.size > 0 ? brothers.values.max : 0

        action = DI[:share_decision].tell_me(mine: connected.size,
                                             brother: big_brother,
                                             free: free.size)

        logger.debug "action #{action}"

        case action
        when :take
          take_device(devices: free, connected_stack: connected_stack)
          next

        when :lazyTake
          if rand(brothers.size + 1) == 0
            take_device(devices: free, connected_stack: connected_stack)
          else
            sleep laziness_delay
          end
          next

        when :return
          return_device(connected_stack: connected_stack)
          next

        when :lazyReturn
          if rand(brothers.size + 1) == 0
            return_device(connected_stack: connected_stack)
          else
            sleep laziness_delay
          end
          next

        when :nothing
          if big_brother - connected.size > 1
            sleep laziness_delay
            next
          end

        end

        sleep delay
      end
    end

    def take_device(devices:, connected_stack:)
      if devices.nil? || devices.empty?
        logger.error 'There is no available devices'
      else
        random_device = devices.asArray.sample
        url = DI[:start_one_debug_session_interactor].execute(random_device)
        connected_stack << url unless url.nil?
      end
    end

    def return_device(connected_stack:)
      url = connected_stack.pop
      if url.nil?
        url = devices.sample
      end
      DI[:stop_debug_session_interactor].execute(url) unless url.nil?
    end

    def get_my_name
      my_devices = DI[:stf].get_user_devices
      return nil if my_devices.nil? || my_devices.empty?
      my_devices.pop.owner.name
    end

    def cleanup_disconnected_devices(filter:, healthcheck:)
      to_disconnect = []
      stf_devices = DeviceList.new(DI[:stf].get_user_devices)

      if filter
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
