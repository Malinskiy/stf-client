require_relative '../lib/stf/client'
require_relative 'support/fake_stf'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /openstf.io/).to_rack(FakeSTF)
  end
end