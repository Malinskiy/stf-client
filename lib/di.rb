require 'dry-container'
require 'dante'
require 'stf/system/demonizer'

require 'stf/interactor/start_debug_session_interactor'
require 'stf/interactor/start_one_debug_session_interactor'
require 'stf/interactor/stop_debug_session_interactor'
require 'stf/interactor/stop_all_debug_sessions_interactor'
require 'stf/interactor/remove_all_user_devices_interactor'
require 'stf/interactor/get_keys_interactor'
require 'stf/interactor/get_values_interactor'

class DI
  class << self
    def init (opts = {})

      c = Dry::Container.new
      @@container = c

      # one time object
      c.register(:dante_runner,
                 -> {Dante::Runner.new('stf-client')})

      # one time object because dante is one time
      c.register(:demonizer,
                 -> do
                   Demonizer.new(c[:dante_runner],
                                 log_path: opts[:log], pid_path: opts[:pid])
                 end)

      c.register(:stf,
                 -> {Stf::Client.new(opts[:url], opts[:token])},
                 memoize: true)

      c.register(:start_debug_session_interactor,
                 -> {StartDebugSessionInteractor.new},
                 memoize: true)

      c.register(:start_one_debug_session_interactor,
                 -> {StartOneDebugSessionInteractor.new},
                 memoize: true)

      c.register(:get_keys_interactor,
                 -> {GetKeysInteractor.new},
                 memoize: true)

      c.register(:get_values_interactor,
                 -> {GetValuesInteractor.new},
                 memoize: true)

      c.register(:stop_all_debug_sessions_interactor,
                 -> {StopAllDebugSessionsInteractor.new},
                 memoize: true)

      c.register(:stop_debug_session_interactor,
                 -> {StopDebugSessionInteractor.new},
                 memoize: true)

      c.register(:remove_all_user_devices_interactor,
                 -> {RemoveAllUserDevicesInteractor.new},
                 memoize: true)

    end

    def [](what)
      @@container.resolve(what)
    end
  end
end