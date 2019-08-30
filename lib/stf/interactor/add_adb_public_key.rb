require 'di'

require 'stf/client'
require 'stf/log/log'

module Stf
  class AddAdbPublicKeyInteractor
    include Log

    def execute(adb_public_key_location)
      public_key = File.open(adb_public_key_location, 'rb', &:read)
      success = DI[:stf].add_adb_public_key public_key
      if success
        logger.info "adb public key from '#{adb_public_key_location}' has been added"
      elsif logger.error "Can't add public key from '#{adb_public_key_location}'"
        return false
      end
    end
  end
end