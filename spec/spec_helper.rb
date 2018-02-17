require 'simplecov'
require_relative '../lib/stf/client'
require_relative 'support/fake_stf'
require 'webmock/rspec'
require 'di'


WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /openstf.io/).to_rack(FakeSTF)

    global_options = Hash.new()
    global_options[:url] = 'http://openstf.io'
    global_options[:token] = FakeSTF.fake_token

    DI.init(global_options)
    DI.container.enable_stubs!
  end
end