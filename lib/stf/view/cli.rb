module Stf
  module CLI
    require 'di'
    require 'gli'

    include GLI::App

    extend self

    program_desc 'Smartphone Test Lab client'

    desc 'Be verbose'
    switch [:v, :verbose]

    desc 'PID file'
    flag [:pid]

    desc 'Log file'
    flag [:log]

    desc 'Authorization token, can also be set by environment variable STF_TOKEN'
    flag [:t, :token]

    desc 'URL to STF, can also be set by environment variable STF_URL'
    flag [:u, :url]

    pre do |global_options, command, options, args|

      global_options[:url] = ENV['STF_URL'] if global_options[:url].nil?
      global_options[:token] = ENV['STF_TOKEN'] if global_options[:token].nil?

      help_now!('STF url is required') if global_options[:url].nil?
      help_now!('Authorization token is required') if global_options[:token].nil?

      Log::verbose(global_options[:verbose])

      DI.init(global_options)
    end

    desc 'Search for a device available in STF and attach it to local adb server'
    command :connect do |c|
      c.desc 'Connect to all available devices'
      c.switch [:all]
      c.desc 'Required quantity of devices'
      c.flag [:n]
      c.desc 'Minimal quantity of devices, n/2 by default'
      c.flag [:min]
      c.desc 'Filter key:value for devices'
      c.flag [:f, :filter]
      c.desc 'Maximum session duration in seconds, 10800 (3h) by default'
      c.flag [:session]
      c.desc 'Maximum time to connect minimal quantity of devices in seconds, 120 (2m) by default'
      c.flag [:starttime]
      c.desc 'Do not start daemon'
      c.switch [:nodaemon]

      c.action do |_, options, _|
        unless DI[:start_debug_session_interactor].execute(options)
          raise GLI::CustomExit.new('Connect failed', 1)
        end
      end
    end

    desc 'Show avaliable keys for filtering'
    command :keys do |c|
      c.action {puts DI[:get_keys_interactor].execute}
    end

    desc 'Show known values for the filtering key'
    command :values do |c|
      c.action do |_, _, args|
        exit_now!('Please specify one key') if args.empty?

        puts DI[:get_values_interactor].execute(args.first)
      end
    end

    desc 'Disconnect device(s) from local adb server and remove device(s) from user devices in STF'
    command :disconnect do |c|
      c.desc '(optional) ADB connection url of the device'
      c.switch [:all]

      c.action do |_, options, args|
        if args.empty? && options[:all] == true
          DI[:stop_all_debug_sessions_interactor].execute
        elsif !args.empty? && options[:all] == false
          DI[:stop_debug_session_interactor].execute(args.first)
        elsif exit_now!('Please specify one device or mode --all')
        end
      end
    end

    desc 'Frees all devices that are assigned to current user in STF. Doesn\'t modify local adb'
    command :clean do |c|
      c.action {DI[:remove_all_user_devices_interactor].execute}
    end

    exit run(ARGV)
  end
end

