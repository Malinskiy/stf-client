module Stf
  module CLI
    require 'gli'
    require 'stf/client'

    require 'stf/interactor/start_debug_session_interactor'
    require 'stf/interactor/stop_debug_session_interactor'
    require 'stf/interactor/stop_all_debug_sessions_interactor'
    require 'stf/interactor/remove_all_user_devices_interactor'
    require 'stf/interactor/get_keys_interactor'
    require 'stf/interactor/get_values_interactor'
    require 'stf/interactor/user_interactor'

    include GLI::App
    extend self

    program_desc 'Smartphone Test Lab client'

    desc 'Be verbose'
    switch [:v, :verbose]

    desc 'Authorization token, can also be set by environment variable STF_TOKEN'
    flag [:t, :token]

    desc 'URL to STF, can also be set by environment variable STF_URL'
    flag [:u, :url]

    pre do |global_options, _command, _options, _args|
      global_options[:url] = ENV['STF_URL'] if global_options[:url].nil?
      global_options[:token] = ENV['STF_TOKEN'] if global_options[:token].nil?

      help_now!('STF url is required') if global_options[:url].nil?
      help_now!('Authorization token is required') if global_options[:token].nil?

      Log.verbose(global_options[:verbose])

      $stf = Stf::Client.new(global_options[:url], global_options[:token])
    end

    desc 'Search for a device available in STF and attach it to local adb server'
    command :connect do |c|
      c.switch [:all]
      c.flag [:n, :number]
      c.flag [:f, :filter]

      c.action do |_global_options, options, _args|
        StartDebugSessionInteractor.new($stf).execute(options[:number], options[:all], options[:filter])
      end
    end

    desc 'Show avaliable keys for filtering'
    command :keys do |c|
      c.action do |_global_options, _options, _args|
        puts GetKeysInteractor.new($stf).execute
      end
    end

    desc 'Show known values for the filtering key'
    command :values do |c|
      c.flag [:k, :key]

      c.action do |_global_options, options, _args|
        if options[:key].nil?
          help_now!('Please specify the key (--key)')
        else
          puts GetValuesInteractor.new($stf).execute(options[:key])
        end
      end
    end

    desc 'Disconnect device(s) from local adb server and remove device(s) from user devices in STF'
    command :disconnect do |c|
      c.desc '(optional) ADB connection url of the device'
      c.flag [:d, :device]
      c.switch [:all]

      c.action do |_global_options, options, _args|
        if options[:device].nil? && options[:all] == true
          StopAllDebugSessionsInteractor.new($stf).execute
        elsif !options[:device].nil? && options[:all] == false
          StopDebugSessionInteractor.new($stf).execute(options[:device])
        elsif help_now!('Please specify disconnect mode (--all or --device)')
        end
      end
    end

    desc 'Frees all devices that are assigned to current user in STF. Doesn\'t modify local adb'
    command :clean do |c|
      c.action do |_global_options, _options, _args|
        RemoveAllUserDevicesInteractor.new($stf).execute
      end
    end

    desc 'Add current adb public key into STF (depends on https://github.com/openstf/stf/pull/770)'
    command :trustme do |c|
      c.flag [:k, :adb_public_key_location], desc: 'Location of adb public key', default_value: '~/.android/adbkey.pub'
      c.action do |_global_options, options, _args|
        options[:adb_public_key_location] = '~/.android/adbkey.pub' if options[:adb_public_key_location].nil?
        filename = File.expand_path(options[:adb_public_key_location])
        unless File.exist? filename
          help_now!("File does not exist: '#{options[:adb_public_key_location]}'")
        end
        UserInteractor.new($stf).execute(options[:adb_public_key_location])
      end
    end

    exit run(ARGV)
  end
end
