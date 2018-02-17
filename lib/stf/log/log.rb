require 'logger'

module Stf
  module Log

    @@logger = Logger.new(STDOUT)
    @@logger.level = Logger::INFO

    def logger
      @@logger
    end

    def self.verbose(enable)
      @@logger.level = enable ? Logger::DEBUG : Logger::INFO
    end

  end
end