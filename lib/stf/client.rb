require 'net/http'
require 'json'
require 'ostruct'

require 'stf/version'
require 'stf/log/log'
require 'stf/errors'

module Stf
  class Client
    include Log

    def initialize(base_url, token)
      @base_url = base_url
      @token    = token
    end

    def get_devices
      response = execute '/api/v1/devices', Net::HTTP::Get
      response.devices
    end

    def get_device(serial)
      response = execute "/api/v1/devices/#{serial}", Net::HTTP::Get
      response.device
    end

    def get_user
      response = execute '/api/v1/user', Net::HTTP::Get
      response.user
    end

    def get_user_devices
      response = execute '/api/v1/user/devices', Net::HTTP::Get
      response.devices
    end

    def add_device(serial)
      response = execute '/api/v1/user/devices', Net::HTTP::Post, { serial: serial }.to_json
      response.success
    end

    def add_adb_public_key(adbkeypub)
      response = execute '/api/v1/user/adbPublicKeys', Net::HTTP::Post, { publickey: adbkeypub }.to_json
      response.success
    end

    def remove_device(serial)
      response = execute "/api/v1/user/devices/#{serial}", Net::HTTP::Delete
      response.success
    end

    def start_debug(serial)
      response = execute "/api/v1/user/devices/#{serial}/remoteConnect", Net::HTTP::Post
      response
    end

    def stop_debug(serial)
      response = execute "/api/v1/user/devices/#{serial}/remoteConnect", Net::HTTP::Delete
      response.success
    end

    private

    def execute(relative_url, type, body = '')
      execute_absolute @base_url + relative_url, type, body
    end

    def execute_absolute(url, type, body = '', limit = 10)
      raise ArgumentError, 'too many HTTP redirects' if limit.zero?

      uri          = URI.parse(url)
      http         = Net::HTTP.new(uri.host, uri.port)
      http.set_debug_output(logger)
      http.use_ssl = true if uri.scheme == 'https'
      request      = type.new(uri, 'Authorization' => "Bearer #{@token}", 'Content-Type' => 'application/json')
      request.body = body
      response     = http.request(request)

      case response
      when Net::HTTPSuccess then
        json = JSON.parse(response.body, object_class: OpenStruct)

        logger.debug "API returned #{json}"
      when Net::HTTPRedirection then
        location = response['location']
        logger.debug "redirected to #{location}"
        return execute_absolute(location, type, body, limit - 1)
      else
        logger.error "API returned #{response.value}"
      end

      json
    end
  end
end
