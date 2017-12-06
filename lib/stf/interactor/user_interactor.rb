require 'ADB'

require 'stf/client'
require 'stf/log/log'
require 'stf/errors'
require 'stf/model/session'

class UserInteractor
  include Log
  def initialize(stf)
    @stf = stf
  end

  def execute(adb_public_key_location)
    public_key = File.open(adb_public_key_location, 'rb', &:read)
    success = @stf.add_adb_public_key public_key
    if success
      logger.info "adb public key from '#{adb_public_key_location}' has been added"
    elsif logger.error "Can't add public key from '#{adb_public_key_location}'"
      return false
    end
  end
end
