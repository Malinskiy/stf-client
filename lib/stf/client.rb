require 'net/http'
require 'json'
require 'ostruct'

require_relative '../stf/version'
require_relative 'errors'
require_relative 'log/log'

module Stf
  class Client
    include Log

    def initialize(base_url, token)
      @base_url = base_url
      @token    = token
    end

    def get_devices
      response = execute '/api/v1/devices', Net::HTTP::Get
      return response.devices
    end

    def get_device(serial)
      response = execute "/api/v1/devices/#{serial}", Net::HTTP::Get
      return response.device
    end

    def get_user
      response = execute '/api/v1/user', Net::HTTP::Get
      return response.user
    end

    def get_user_devices
      response = execute '/api/v1/user/devices', Net::HTTP::Get
      return response.devices
    end

    def add_device(serial)
      response = execute '/api/v1/user/devices', Net::HTTP::Post, {serial: serial}.to_json
      return response.success
    end

    def remove_device(serial)
      response = execute "/api/v1/user/devices/#{serial}", Net::HTTP::Delete
      return response.success
    end

    def start_debug(serial)
      response = execute "/api/v1//user/devices/#{serial}/remoteConnect", Net::HTTP::Post
      return response
    end

    def stop_debug(serial)
      response = execute "/api/v1//user/devices/#{serial}/remoteConnect", Net::HTTP::Delete
      return response.success
    end

    private

    def execute(relative_url, type, body='')
      uri          = URI.parse(@base_url + relative_url)
      http         = Net::HTTP.new(uri.host)
      request      = type.new(uri.request_uri, 'Authorization' => "Bearer #{@token}", 'Content-Type' => 'application/json')
      request.body = body
      response     = http.request(request)


      json = JSON.parse(response.body, object_class: OpenStruct)

      logger.debug "API returned #{json}"

      return json
    end
  end
end
