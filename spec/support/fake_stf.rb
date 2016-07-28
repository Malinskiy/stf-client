require 'sinatra/base'

class FakeSTF < Sinatra::Base
  get '/api/v1/devices' do
    return 404 unless @env['HTTP_AUTHORIZATION'].eql? "Bearer #{FakeSTF.fake_token}"

    json_response 200, 'GET_devices.json'
  end

  get '/api/v1/devices/:serial' do
    return 404 unless @env['HTTP_AUTHORIZATION'].eql? "Bearer #{FakeSTF.fake_token}"

    json_response 200, 'devices/GET_device.json'
  end

  get '/api/v1/user' do
    return 404 unless @env['HTTP_AUTHORIZATION'].eql? "Bearer #{FakeSTF.fake_token}"

    json_response 200, 'GET_user.json'
  end

  get '/api/v1/user/devices' do
    return 404 unless @env['HTTP_AUTHORIZATION'].eql? "Bearer #{FakeSTF.fake_token}"

    json_response 200, 'user/GET_devices.json'
  end

  post '/api/v1/user/devices' do
    return 404 unless @env['HTTP_AUTHORIZATION'].eql? "Bearer #{FakeSTF.fake_token}"

    json_response 200, 'user/POST_devices.json'
  end

  post '/api/v1/user/devices/:serial/remoteConnect' do
    return 404 unless @env['HTTP_AUTHORIZATION'].eql? "Bearer #{FakeSTF.fake_token}"

    json_response 200, 'user/devices/POST_remoteConnect.json'
  end

  delete '/api/v1/user/devices/:serial/remoteConnect' do
    return 404 unless @env['HTTP_AUTHORIZATION'].eql? "Bearer #{FakeSTF.fake_token}"

    json_response 200, 'user/devices/DELETE_remoteConnect.json'
  end

  delete '/api/v1/user/devices/:serial' do
    return 404 unless @env['HTTP_AUTHORIZATION'].eql? "Bearer #{FakeSTF.fake_token}"

    json_response 200, 'user/DELETE_devices.json'
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb').read
  end

  def self.fake_token
    'FAKE_TOKEN'
  end
end