require 'dry-container'
require 'dante'
require 'stf/system/demonizer'

require 'stf/interactor/start_debug_session_interactor'
require 'stf/interactor/start_debug_share_interactor'
require 'stf/interactor/start_one_debug_session_interactor'
require 'stf/interactor/stop_debug_session_interactor'
require 'stf/interactor/stop_all_debug_sessions_interactor'
require 'stf/interactor/remove_all_user_devices_interactor'
require 'stf/interactor/get_keys_interactor'
require 'stf/interactor/get_values_interactor'
require 'stf/share/decision'
require 'stf/interactor/add_adb_public_key'
require 'stf/validate/uri_validator'

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
                   Stf::Demonizer.new(c[:dante_runner],
                                 log_path: opts[:log], pid_path: opts[:pid])
                 end)

      c.register(:stf,
                 -> {Stf::Client.new(opts[:url], opts[:token])},
                 memoize: true)

      c.register(:share_decision,
                 -> {Stf::Decision.new},
                 memoize: true)

      c.register(:start_debug_session_interactor,
                 -> {Stf::StartDebugSessionInteractor.new},
                 memoize: true)

      c.register(:start_debug_share_interactor,
                 -> {Stf::StartDebugShareInteractor.new(c[:share_decision])},
                 memoize: true)

      c.register(:start_one_debug_session_interactor,
                 -> {Stf::StartOneDebugSessionInteractor.new},
                 memoize: true)

      c.register(:get_keys_interactor,
                 -> {Stf::GetKeysInteractor.new},
                 memoize: true)

      c.register(:get_values_interactor,
                 -> {Stf::GetValuesInteractor.new},
                 memoize: true)

      c.register(:stop_all_debug_sessions_interactor,
                 -> {Stf::StopAllDebugSessionsInteractor.new},
                 memoize: true)

      c.register(:stop_debug_session_interactor,
                 -> {Stf::StopDebugSessionInteractor.new},
                 memoize: true)

      c.register(:remove_all_user_devices_interactor,
                 -> {Stf::RemoveAllUserDevicesInteractor.new},
                 memoize: true)

      c.register(:uri_validator,
                 -> {Stf::URIValidator.new},
                 memoize: true)

      c.register(:add_adb_public_key_interactor,
                 -> {Stf::AddAdbPublicKeyInteractor.new},
                 memoize: true)
    end

    def [](what)
      @@container.resolve(what)
    end

    def container
      @@container
    end
  end
end